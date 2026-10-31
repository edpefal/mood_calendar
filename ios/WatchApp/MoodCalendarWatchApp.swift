import SwiftUI

@main
struct MoodCalendarWatchApp: App {
  @StateObject private var model: WatchModel
  @Environment(\.scenePhase) private var scenePhase
  private let link: PhoneLink

  init() {
    let model = WatchModel()
    let link = PhoneLink(model: model)
    link.start()
    _model = StateObject(wrappedValue: model)
    self.link = link
  }

  var body: some Scene {
    WindowGroup {
      ContentView(model: model, send: link.send)
        .onChange(of: scenePhase) { phase in
          if phase == .active { link.refreshFromSession() }
        }
    }
  }
}
