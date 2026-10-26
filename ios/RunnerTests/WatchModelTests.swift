import XCTest
@testable import Runner

/// Tests the watch app's model. WatchModel.swift and WatchModels.swift are plain
/// Foundation, so the RunnerTests target compiles them directly.
final class WatchModelTests: XCTestCase {
  private var suite: String!
  private var defaults: UserDefaults!
  private var day = "2026-11-02"

  override func setUp() {
    super.setUp()
    suite = "WatchModelTests-\(UUID().uuidString)"
    defaults = UserDefaults(suiteName: suite)
    day = "2026-11-02"
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: suite)
    super.tearDown()
  }

  private func makeModel() -> WatchModel {
    WatchModel(defaults: defaults, today: { self.day })
  }

  private func context(today: String? = nil, version: Int = 1) -> [String: Any] {
    var context: [String: Any] = [
      "version": version,
      "locale": "es",
      "moods": [["id": "calm", "name": "Tranquilo"], ["id": "happy", "name": "Feliz"]],
    ]
    if let today { context["today"] = today }
    return context
  }

  func testParsesTheContract() {
    let state = WatchAppState(context: context(today: "calm"))
    XCTAssertEqual(state?.today, "calm")
    XCTAssertEqual(state?.locale, "es")
    XCTAssertEqual(state?.moods.map(\.id), ["calm", "happy"])
    XCTAssertEqual(state?.moods.first?.name, "Tranquilo")
  }

  func testTodayIsOptional() {
    XCTAssertNil(WatchAppState(context: context())?.today)
  }

  func testRejectsNewerVersionAndMalformedContext() {
    XCTAssertNil(WatchAppState(context: context(version: 2)))
    XCTAssertNil(WatchAppState(context: [:]))
    XCTAssertNil(WatchAppState(context: ["version": 1]))
  }

  func testSkipsMalformedMoodsButKeepsTheRest() {
    let state = WatchAppState(context: [
      "version": 1,
      "moods": [["id": "calm", "name": "Calm"], ["id": "x"], ["name": "y"]],
    ])
    XCTAssertEqual(state?.moods.map(\.id), ["calm"])
  }

  func testChooseBuildsOnlyContractFields() {
    let model = makeModel()
    let when = Date(timeIntervalSince1970: 1_793_617_800)
    let info = model.choose(WatchMood(id: "calm", name: "Calm"), at: when)

    XCTAssertEqual(Set(info.keys), ["id", "date", "mood", "chosenAt"])
    XCTAssertEqual(info["mood"] as? String, "calm")
    XCTAssertEqual(info["chosenAt"] as? Double, 1_793_617_800_000)
    XCTAssertNotNil(UUID(uuidString: info["id"] as? String ?? ""))
    XCTAssertEqual(info["date"] as? String, WatchDate.localString(when))
  }

  func testPendingChoiceIsHighlightedUntilThePhoneConfirms() {
    let model = makeModel()
    model.apply(context: context(today: "happy"))
    _ = model.choose(WatchMood(id: "calm", name: "Calm"))
    // choose() stamps the real current day; align the test clock with it.
    day = WatchDate.localString()

    XCTAssertTrue(model.isPending)
    XCTAssertEqual(model.todayMood, "calm")

    model.apply(context: context(today: "calm"))
    XCTAssertFalse(model.isPending)
    XCTAssertEqual(model.todayMood, "calm")
  }

  func testPendingStaysWhenThePhoneConfirmsAnotherMood() {
    let model = makeModel()
    day = WatchDate.localString()
    _ = model.choose(WatchMood(id: "sad", name: "Sad"))

    model.apply(context: context(today: "calm"))

    XCTAssertTrue(model.isPending)
    XCTAssertEqual(model.todayMood, "sad")
  }

  func testStalePendingIsDroppedWhenTheDayChanges() {
    let model = makeModel()
    day = WatchDate.localString()
    _ = model.choose(WatchMood(id: "sad", name: "Sad"))
    XCTAssertTrue(model.isPending)

    day = "2999-01-01"
    model.apply(context: context(today: nil))

    XCTAssertFalse(model.isPending)
    XCTAssertNil(model.todayMood)
  }

  func testStateAndPendingSurviveRestart() {
    let first = makeModel()
    first.apply(context: context(today: "happy"))
    day = WatchDate.localString()
    _ = first.choose(WatchMood(id: "calm", name: "Calm"))

    let second = makeModel()
    XCTAssertEqual(second.state?.moods.count, 2)
    XCTAssertEqual(second.pending?.mood, "calm")
  }

  func testLocalDateFormat() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Mexico_City")!
    // 2026-11-03 05:30 UTC is still 23:30 on 2026-11-02 in Mexico City.
    let late = Date(timeIntervalSince1970: 1_793_683_800)
    XCTAssertEqual(WatchDate.localString(late, calendar: calendar), "2026-11-02")
  }
}
