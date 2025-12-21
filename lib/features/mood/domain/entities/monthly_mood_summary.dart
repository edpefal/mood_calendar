import 'mood_entry.dart';

class MonthlyMoodSummary {
  final DateTime month;
  final List<MoodEntry> entries;
  final double averageScore;
  final int bestStreak;
  final MoodEntry? lastEntry;

  MonthlyMoodSummary({
    required this.month,
    required this.entries,
    required this.averageScore,
    required this.bestStreak,
    required this.lastEntry,
  });
}
