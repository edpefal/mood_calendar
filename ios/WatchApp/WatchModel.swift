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
    let id = UUID().uuidString
    savePending(PendingChoice(mood: mood.id, date: day, id: id))
    return [
      "id": id,
      "date": day,
      "mood": mood.id,
      "chosenAt": date.timeIntervalSince1970 * 1000,
    ]
  }

  /// Drops the pending marker once the iPhone reports that mood for today, once
  /// the iPhone says it processed this very choice (it may have discarded it,
  /// e.g. a mood that is no longer unlocked), or when the day has changed (a
  /// stale choice must not stay highlighted). A state that does not mention the
  /// choice, such as one sent after a language change, keeps the marker.
  private func reconcilePending() {
    guard let pending else { return }
    if pending.date != today() || state?.today == pending.mood || isHandled(pending) {
      savePending(nil)
    }
  }

  private func isHandled(_ pending: PendingChoice) -> Bool {
    guard let id = pending.id else { return false }
    return state?.handledChoiceIds.contains(id) == true
  }

  private func savePending(_ value: PendingChoice?) {
    pending = value
    defaults.set(value.flatMap { try? JSONEncoder().encode($0) }, forKey: Self.pendingKey)
  }
}
