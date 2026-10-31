import Foundation

/// A mood the watch can offer, with its name already localized by the iPhone.
struct WatchMood: Equatable, Identifiable {
  let id: String
  let name: String
}

/// State published by the iPhone (docs/watch-sync-contract.md).
struct WatchAppState: Equatable {
  static let supportedVersion = 1

  let locale: String
  let today: String?
  let moods: [WatchMood]

  /// Ids of the latest watch choices the iPhone already processed, applied or
  /// discarded. Optional in the contract: an older state simply has none.
  let handledChoiceIds: [String]

  /// Returns nil when the context does not follow the contract or comes from a
  /// newer version than this app understands.
  init?(context: [String: Any]) {
    guard let version = context["version"] as? Int,
          version <= Self.supportedVersion,
          let rawMoods = context["moods"] as? [[String: Any]]
    else { return nil }
    locale = context["locale"] as? String ?? "en"
    today = context["today"] as? String
    handledChoiceIds = context["handledChoiceIds"] as? [String] ?? []
    moods = rawMoods.compactMap { raw in
      guard let id = raw["id"] as? String, let name = raw["name"] as? String else { return nil }
      return WatchMood(id: id, name: name)
    }
  }
}

/// A choice made on the watch that the iPhone has not confirmed yet.
struct PendingChoice: Codable, Equatable {
  let mood: String
  let date: String

  /// Id of the choice sent to the iPhone. Missing in choices saved by an
  /// earlier version of the app.
  var id: String? = nil
}

enum WatchDate {
  /// Local date as `YYYY-MM-DD`, the day the choice belongs to.
  static func localString(_ date: Date = Date(), calendar: Calendar = .current) -> String {
    let parts = calendar.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
  }
}
