class MoodStreakCalculator {
  /// Computes the longest run of consecutive calendar days in [sortedDates].
  ///
  /// [sortedDates] must already be sorted ascending. Two dates are
  /// consecutive when they are exactly one calendar day apart, regardless of
  /// whether that day crosses a month or year boundary (e.g. Jan 31 -> Feb 1,
  /// or Dec 31 -> Jan 1).
  static int bestStreak(List<DateTime> sortedDates) {
    if (sortedDates.isEmpty) return 0;

    int bestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < sortedDates.length; i++) {
      final previousDate = sortedDates[i - 1];
      final currentDate = sortedDates[i];
      final isConsecutive =
          currentDate.difference(previousDate).inDays == 1;

      if (isConsecutive) {
        currentStreak++;
      } else {
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
        currentStreak = 1;
      }
    }

    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
    return bestStreak;
  }
}
