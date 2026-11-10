import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Active before Dart runs, so choices from the Apple Watch reach a closed app.
    WatchBridge.shared.activate()
    // Without this delegate iOS never tells flutter_local_notifications that the
    // daily reminder was tapped, so the app opened on its last screen instead of
    // the Log. FlutterAppDelegate forwards the callbacks to the plugin.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "WatchBridge") {
      WatchBridge.shared.attach(messenger: registrar.messenger())
    }
  }
}
