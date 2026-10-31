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

  private func context(
    today: String? = nil,
    version: Int = 1,
    handled: [String]? = nil
  ) -> [String: Any] {
    var context: [String: Any] = [
      "version": version,
      "locale": "es",
      "moods": [["id": "calm", "name": "Tranquilo"], ["id": "happy", "name": "Feliz"]],
    ]
    if let today { context["today"] = today }
    if let handled { context["handledChoiceIds"] = handled }
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

  func testHandledChoiceIdsAreOptionalAndParsed() {
    XCTAssertEqual(WatchAppState(context: context())?.handledChoiceIds, [])
    XCTAssertEqual(
      WatchAppState(context: context(handled: ["a", "b"]))?.handledChoiceIds,
      ["a", "b"]
    )
  }

  func testChooseReturnsTheIdItKeepsInThePendingChoice() {
    let model = makeModel()
    let info = model.choose(WatchMood(id: "calm", name: "Calm"))

    XCTAssertEqual(model.pending?.id, info["id"] as? String)
  }

  func testPendingIsDroppedWhenThePhoneReportsItProcessedThatChoice() {
    // The iPhone discarded the choice (the mood is no longer unlocked) and says
    // so by listing its id, even though today's mood does not match.
    let model = makeModel()
    day = WatchDate.localString()
    let info = model.choose(WatchMood(id: "brave", name: "Brave"))
    let id = info["id"] as! String

    model.apply(context: context(today: "happy", handled: [id]))

    XCTAssertFalse(model.isPending)
    XCTAssertEqual(model.todayMood, "happy")
  }

  func testPendingStaysWhenTheStateDoesNotMentionTheChoice() {
    // E.g. a state published after a language change while the choice is still
    // queued: it must not clear the marker early.
    let model = makeModel()
    day = WatchDate.localString()
    _ = model.choose(WatchMood(id: "calm", name: "Calm"))

    model.apply(context: context(today: "happy", handled: ["some-other-id"]))

    XCTAssertTrue(model.isPending)
    XCTAssertEqual(model.todayMood, "calm")
  }

  func testPendingStaysWhenAnOlderChoiceWasHandled() {
    let model = makeModel()
    day = WatchDate.localString()
    let first = model.choose(WatchMood(id: "calm", name: "Calm"))["id"] as! String
    _ = model.choose(WatchMood(id: "sad", name: "Sad"))

    model.apply(context: context(today: "calm", handled: [first]))

    XCTAssertEqual(model.pending?.mood, "sad")
  }

  func testAPendingChoiceSavedBeforeIdsExistStillLoads() throws {
    // A choice persisted by the previous app version has no id.
    let legacy = #"{"mood":"calm","date":"\#(WatchDate.localString())"}"#
    defaults.set(Data(legacy.utf8), forKey: WatchModel.pendingKey)
    day = WatchDate.localString()

    let model = makeModel()

    XCTAssertEqual(model.pending?.mood, "calm")
    XCTAssertNil(model.pending?.id)
    model.apply(context: context(today: "happy", handled: ["x"]))
    XCTAssertTrue(model.isPending)
  }

  func testLocalDateFormat() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "America/Mexico_City")!
    // 2026-11-03 05:30 UTC is still 23:30 on 2026-11-02 in Mexico City.
    let late = Date(timeIntervalSince1970: 1_793_683_800)
    XCTAssertEqual(WatchDate.localString(late, calendar: calendar), "2026-11-02")
  }
}
