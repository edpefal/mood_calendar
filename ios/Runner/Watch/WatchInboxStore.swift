import Foundation

/// A mood chosen on the Apple Watch, waiting to be applied by the Dart side.
/// See docs/watch-sync-contract.md.
struct WatchChoice: Codable, Equatable {
  let id: String
  let date: String
  let mood: String
  let chosenAt: Double

  init?(userInfo: [String: Any]) {
    guard let id = userInfo["id"] as? String, !id.isEmpty,
          let date = userInfo["date"] as? String,
          let mood = userInfo["mood"] as? String, !mood.isEmpty,
          let chosenAt = (userInfo["chosenAt"] as? NSNumber)?.doubleValue
    else { return nil }
    self.id = id
    self.date = date
    self.mood = mood
    self.chosenAt = chosenAt
  }

  var dictionary: [String: Any] {
    ["id": id, "date": date, "mood": mood, "chosenAt": chosenAt]
  }
}

/// Persistent inbox of watch choices. Swift only appends and Dart acknowledges
/// after saving to Hive, so a choice is never lost if the app dies in between.
final class WatchInboxStore {
  static let inboxKey = "watch.inbox.v1"
  static let seenKey = "watch.inbox.seen.v1"
  static let maxSeen = 200

  private let defaults: UserDefaults
  private let lock = NSLock()

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  /// Returns false when the choice was already received (same id), even if it
  /// was already acknowledged: the system may redeliver a user info.
  @discardableResult
  func append(_ choice: WatchChoice) -> Bool {
    lock.lock()
    defer { lock.unlock() }
    var seen = defaults.stringArray(forKey: Self.seenKey) ?? []
    if seen.contains(choice.id) { return false }
    seen.append(choice.id)
    if seen.count > Self.maxSeen { seen.removeFirst(seen.count - Self.maxSeen) }
    defaults.set(seen, forKey: Self.seenKey)
    var items = load()
    items.append(choice)
    save(items)
    return true
  }

  func read() -> [WatchChoice] {
    lock.lock()
    defer { lock.unlock() }
    return load()
  }

  func remove(ids: [String]) {
    lock.lock()
    defer { lock.unlock() }
    let drop = Set(ids)
    save(load().filter { !drop.contains($0.id) })
  }

  private func load() -> [WatchChoice] {
    guard let data = defaults.data(forKey: Self.inboxKey),
          let items = try? JSONDecoder().decode([WatchChoice].self, from: data)
    else { return [] }
    return items
  }

  private func save(_ items: [WatchChoice]) {
    defaults.set(try? JSONEncoder().encode(items), forKey: Self.inboxKey)
  }
}
