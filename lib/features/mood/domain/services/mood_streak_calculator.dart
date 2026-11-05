class MoodStreakCalculator {
  /// Consecutive calendar days with an entry that end at [endingAt] (which
  /// counts as day one when it has an entry). 0 when [endingAt] has none.
  ///
  /// Days step by calendar arithmetic, not by 24-hour differences, so a
  /// daylight-saving change never splits a streak, and the run crosses month
  /// and year boundaries like any other day.
  static int currentStreak(Iterable<DateTime> entryDates, DateTime endingAt) {
    final days = {
      for (final date in entryDates) DateTime(date.year, date.month, date.day),
    };
    var day = DateTime(endingAt.year, endingAt.month, endingAt.day);
    var count = 0;
    while (days.contains(day)) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

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
      final isConsecutive = currentDate.difference(previousDate).inDays == 1;

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
