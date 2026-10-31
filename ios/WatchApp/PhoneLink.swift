import Foundation
import WatchConnectivity

/// Watch side of WatchConnectivity: receives the iPhone's state and sends the
/// user's choices through a persistent queue, so a choice made away from the
/// iPhone is delivered later and never lost.
final class PhoneLink: NSObject, WCSessionDelegate {
  private weak var model: WatchModel?

  init(model: WatchModel) {
    self.model = model
    super.init()
  }

  func start() {
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }

  func send(_ userInfo: [String: Any]) {
    guard WCSession.isSupported() else { return }
    WCSession.default.transferUserInfo(userInfo)
  }

  /// The latest context may have arrived while the app was closed.
  func refreshFromSession() {
    guard WCSession.isSupported() else { return }
    let context = WCSession.default.receivedApplicationContext
    if !context.isEmpty { apply(context) }
  }

  private func apply(_ context: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.model?.apply(context: context)
    }
  }

  // MARK: WCSessionDelegate

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if activationState == .activated { refreshFromSession() }
  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    apply(applicationContext)
  }
}
