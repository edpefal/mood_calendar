import '../services/mood_streak_calculator.dart';
import 'mood_entry.dart';

class MonthlyMoodSummary {
  final DateTime month;
  final List<MoodEntry> entries;
  final MoodEntry? mostCommonMoodEntry;
  final int bestStreak;
  final MoodEntry? lastEntry;

  MonthlyMoodSummary({
    required this.month,
    required this.entries,
    required this.mostCommonMoodEntry,
    required this.bestStreak,
    required this.lastEntry,
  });

  /// The summary of [month] from [monthEntries] (entries of that month only,
  /// in any order): entries sorted by date, the most common mood (ties go to
  /// the one logged most recently) and the best streak.
  factory MonthlyMoodSummary.fromEntries(
    DateTime month,
    Iterable<MoodEntry> monthEntries,
  ) {
    final sorted = [...monthEntries]..sort((a, b) => a.date.compareTo(b.date));
    return MonthlyMoodSummary(
      month: DateTime(month.year, month.month),
      entries: sorted,
      mostCommonMoodEntry: _mostCommon(sorted),
      bestStreak: MoodStreakCalculator.bestStreak(
        [for (final entry in sorted) entry.date],
      ),
      lastEntry: sorted.isNotEmpty ? sorted.last : null,
    );
  }

  static MoodEntry? _mostCommon(List<MoodEntry> entries) {
    if (entries.isEmpty) return null;
    final countByMood = <String, int>{};
    for (final entry in entries) {
      countByMood[entry.mood] = (countByMood[entry.mood] ?? 0) + 1;
    }
    final maxCount = countByMood.values
        .fold<int>(0, (max, count) => count > max ? count : max);
    final tied = {
      for (final e in countByMood.entries)
        if (e.value == maxCount) e.key,
    };
    MoodEntry? best;
    for (final entry in entries) {
      if (!tied.contains(entry.mood)) continue;
      if (best == null || entry.date.isAfter(best.date)) best = entry;
    }
    return best;
  }
}
