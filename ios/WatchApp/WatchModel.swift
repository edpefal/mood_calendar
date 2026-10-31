import Foundation

/// What the watch shows: the last state received from the iPhone and the
/// choice still waiting for the iPhone to confirm. The watch keeps no history;
/// the iPhone (Hive) is the only source of truth.
final class WatchModel: ObservableObject {
  static let stateKey = "watch.state.v1"
  static let pendingKey = "watch.pending.v1"

  @Published private(set) var state: WatchAppState?
  @Published private(set) var pending: PendingChoice?

  private let defaults: UserDefaults
  private let today: () -> String

  init(defaults: UserDefaults = .standard, today: @escaping () -> String = { WatchDate.localString() }) {
    self.defaults = defaults
    self.today = today
    if let context = defaults.dictionary(forKey: Self.stateKey) {
      state = WatchAppState(context: context)
    }
    if let data = defaults.data(forKey: Self.pendingKey) {
      pending = try? JSONDecoder().decode(PendingChoice.self, from: data)
    }
    reconcilePending()
  }

  /// Mood to highlight: the pending choice first, then the iPhone's mood of today.
  var todayMood: String? {
    pending?.mood ?? state?.today
  }

  var isPending: Bool { pending != nil }

  func apply(context: [String: Any]) {
    guard let next = WatchAppState(context: context) else { return }
    defaults.set(context, forKey: Self.stateKey)
    state = next
    reconcilePending()
  }

  /// Registers the choice for today and returns the user info to send.
  func choose(_ mood: WatchMood, at date: Date = Date()) -> [String: Any] {
    let day = WatchDate.localString(date)
    savePending(PendingChoice(mood: mood.id, date: day))
    return [
      "id": UUID().uuidString,
      "date": day,
      "mood": mood.id,
      "chosenAt": date.timeIntervalSince1970 * 1000,
    ]
  }

  /// Drops the pending marker once the iPhone reports that mood for today, or
  /// when the day has changed (a stale choice must not stay highlighted).
  private func reconcilePending() {
    guard let pending else { return }
    if pending.date != today() || state?.today == pending.mood {
      savePending(nil)
    }
  }

  private func savePending(_ value: PendingChoice?) {
    pending = value
    defaults.set(value.flatMap { try? JSONEncoder().encode($0) }, forKey: Self.pendingKey)
  }
}
