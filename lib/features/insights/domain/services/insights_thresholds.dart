/// Minimum amount of data before a card draws anything. Below these the card
/// shows its "not enough data" state instead of a chart that says nothing.
/// Kept in one place so they can be tuned after trying the app with real use.
class InsightsThresholds {
  const InsightsThresholds._();

  /// Entries needed in the chosen trend range.
  static const minEntriesPerTrendRange = 2;

  /// Entries needed on a weekday for its bar to show.
  static const minEntriesPerWeekday = 2;

  /// Entries needed in total for the weekday card to show anything.
  static const minEntriesForWeekdayProfile = 14;
}
