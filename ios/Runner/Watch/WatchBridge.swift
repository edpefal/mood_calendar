import Flutter
import Foundation
import WatchConnectivity

/// iPhone side of the Apple Watch sync (docs/watch-sync-contract.md).
/// Receives the watch's choices into WatchInboxStore and publishes the app
/// state to the watch. It never touches Hive: Dart reads the inbox through the
/// method channel and acknowledges what it applied.
final class WatchBridge: NSObject, WCSessionDelegate {
  static let shared = WatchBridge()
  static let channelName = "com.artlab.moodcalendar/watch"
  private static let stateKey = "watch.published.state.v1"

  private let inbox = WatchInboxStore()
  private var channel: FlutterMethodChannel?
  private var session: WCSession? { WCSession.isSupported() ? WCSession.default : nil }

  /// Called from application(_:didFinishLaunchingWithOptions:): the session has
  /// to be active at launch for the system to deliver watch data to a closed app.
  func activate() {
    guard let session else { return }
    session.delegate = self
    session.activate()
  }

  func attach(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    self.channel = channel
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "readInbox":
      result(inbox.read().map { $0.dictionary })
    case "ackInbox":
      let args = call.arguments as? [String: Any]
      inbox.remove(ids: (args?["ids"] as? [String]) ?? [])
      result(nil)
    case "publishState":
      if let state = call.arguments as? [String: Any] {
        // Dart sends `today: null` when there is no entry; NSNull is not a
        // property-list value, so UserDefaults and WatchConnectivity reject it.
        let cleaned = state.filter { !($0.value is NSNull) }
        UserDefaults.standard.set(cleaned, forKey: Self.stateKey)
        sendLastState()
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Sends the last published state; harmless when no watch is paired or the
  /// watch app is not installed (it is sent again when that changes).
  private func sendLastState() {
    guard let session, session.activationState == .activated,
          session.isPaired, session.isWatchAppInstalled,
          let state = UserDefaults.standard.dictionary(forKey: Self.stateKey)
    else { return }
    try? session.updateApplicationContext(state)
  }

  // MARK: WCSessionDelegate

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if activationState == .activated { sendLastState() }
  }

  func sessionWatchStateDidChange(_ session: WCSession) {
    sendLastState()
  }

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
    guard let choice = WatchChoice(userInfo: userInfo), inbox.append(choice) else { return }
    DispatchQueue.main.async { [weak self] in
      self?.channel?.invokeMethod("inboxChanged", arguments: nil)
    }
  }
}
