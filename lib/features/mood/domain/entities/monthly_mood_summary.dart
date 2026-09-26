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
}
