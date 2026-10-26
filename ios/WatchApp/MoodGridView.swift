import SwiftUI
import UIKit

/// Two-column grid of the moods the user has unlocked, in the iPhone's usage
/// order. Tapping one registers it as today's mood.
struct MoodGridView: View {
  let moods: [WatchMood]
  let selectedId: String?
  let isPending: Bool
  let onSelect: (WatchMood) -> Void

  private let columns = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]

  var body: some View {
    ScrollView {
      VStack(spacing: 8) {
        Text("watch.title", comment: "Prompt above the mood grid")
          .font(.headline)
          .multilineTextAlignment(.center)
        if isPending {
          Label {
            Text("watch.pending", comment: "The choice has not reached the iPhone yet")
          } icon: {
            Image(systemName: "arrow.triangle.2.circlepath")
          }
          .font(.caption2)
          .foregroundColor(.secondary)
        }
        LazyVGrid(columns: columns, spacing: 6) {
          ForEach(moods) { mood in
            MoodTile(mood: mood, isSelected: mood.id == selectedId) { onSelect(mood) }
          }
        }
      }
      .padding(.horizontal, 4)
    }
  }
}

struct MoodTile: View {
  static let accent = Color(red: 0x6C / 255, green: 0x63 / 255, blue: 0xFF / 255)

  let mood: WatchMood
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 2) {
        MoodIcon(id: mood.id)
          .frame(width: 44, height: 44)
        Text(mood.name)
          .font(.caption2)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 6)
      .background(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .fill(Color.white.opacity(0.12))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(isSelected ? Self.accent : Color.clear, lineWidth: 3)
      )
    }
    .buttonStyle(.plain)
    .accessibilityLabel(mood.name)
    .accessibilityAddTraits(isSelected ? [.isSelected] : [])
  }
}

/// The mood face from the asset catalog; a plain circle if a newer iPhone app
/// offers a mood this watch app has no icon for yet.
struct MoodIcon: View {
  let id: String

  var body: some View {
    if UIImage(named: "mood_\(id)") != nil {
      Image("mood_\(id)")
        .resizable()
        .scaledToFit()
        .accessibilityHidden(true)
    } else {
      Circle().fill(Color.white.opacity(0.25))
    }
  }
}
