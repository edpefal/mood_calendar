import SwiftUI
import WatchKit

struct ContentView: View {
  @ObservedObject var model: WatchModel
  let send: ([String: Any]) -> Void

  var body: some View {
    if let state = model.state, !state.moods.isEmpty {
      MoodGridView(
        moods: state.moods,
        selectedId: model.todayMood,
        isPending: model.isPending
      ) { mood in
        send(model.choose(mood))
        WKInterfaceDevice.current().play(.success)
      }
    } else {
      EmptyStateView()
    }
  }
}

/// Shown until the iPhone publishes the state for the first time.
struct EmptyStateView: View {
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: "iphone")
        .font(.title2)
        .foregroundColor(.secondary)
        .accessibilityHidden(true)
      Text("watch.empty", comment: "Asks the user to open the app on the iPhone")
        .multilineTextAlignment(.center)
    }
    .padding()
  }
}
