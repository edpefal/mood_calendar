import XCTest
@testable import Runner

final class WatchInboxStoreTests: XCTestCase {
  private var suite: String!
  private var defaults: UserDefaults!

  override func setUp() {
    super.setUp()
    suite = "WatchInboxStoreTests-\(UUID().uuidString)"
    defaults = UserDefaults(suiteName: suite)
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: suite)
    super.tearDown()
  }

  private func choice(_ id: String, mood: String = "calm", at: Double = 1) -> WatchChoice {
    WatchChoice(userInfo: ["id": id, "date": "2026-11-02", "mood": mood, "chosenAt": at])!
  }

  func testAppendAndRead() {
    let store = WatchInboxStore(defaults: defaults)
    XCTAssertTrue(store.append(choice("a")))
    XCTAssertTrue(store.append(choice("b", mood: "sad", at: 2)))
    XCTAssertEqual(store.read().map(\.id), ["a", "b"])
    XCTAssertEqual(store.read().last?.mood, "sad")
  }

  func testDuplicateIdIsIgnored() {
    let store = WatchInboxStore(defaults: defaults)
    XCTAssertTrue(store.append(choice("a")))
    XCTAssertFalse(store.append(choice("a")))
    XCTAssertEqual(store.read().count, 1)
  }

  func testRemoveOnlyAcknowledgedIds() {
    let store = WatchInboxStore(defaults: defaults)
    store.append(choice("a"))
    store.append(choice("b"))
    store.remove(ids: ["a"])
    XCTAssertEqual(store.read().map(\.id), ["b"])
  }

  func testRedeliveryAfterAckIsNotReapplied() {
    let store = WatchInboxStore(defaults: defaults)
    store.append(choice("a"))
    store.remove(ids: ["a"])
    XCTAssertFalse(store.append(choice("a")))
    XCTAssertTrue(store.read().isEmpty)
  }

  func testSurvivesNewInstance() {
    WatchInboxStore(defaults: defaults).append(choice("a"))
    XCTAssertEqual(WatchInboxStore(defaults: defaults).read().map(\.id), ["a"])
  }

  func testSeenIdsAreBounded() {
    let store = WatchInboxStore(defaults: defaults)
    for i in 0..<(WatchInboxStore.maxSeen + 20) { store.append(choice("id-\(i)")) }
    let seen = defaults.stringArray(forKey: WatchInboxStore.seenKey) ?? []
    XCTAssertEqual(seen.count, WatchInboxStore.maxSeen)
  }

  func testMalformedUserInfoIsRejected() {
    XCTAssertNil(WatchChoice(userInfo: [:]))
    XCTAssertNil(WatchChoice(userInfo: ["id": "a", "date": "2026-11-02", "mood": "", "chosenAt": 1]))
    XCTAssertNil(WatchChoice(userInfo: ["id": "a", "date": "2026-11-02", "mood": "calm"]))
  }
}
