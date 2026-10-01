import '../entities/monthly_mood_summary.dart';
import '../entities/mood_entry.dart';
import '../services/mood_streak_calculator.dart';
import 'get_moods_for_month_usecase.dart';

class GetMonthlyMoodSummaryUseCase {
  final GetMoodsForMonthUseCase getMoodsForMonth;

  GetMonthlyMoodSummaryUseCase(this.getMoodsForMonth);

  Future<MonthlyMoodSummary> call(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    final entries = await getMoodsForMonth(normalizedMonth);
    final sortedEntries = [...entries]
      ..sort((a, b) => a.date.compareTo(b.date));

    final bestStreak = MoodStreakCalculator.bestStreak(
      sortedEntries.map((entry) => entry.date).toList(),
    );
    final lastEntry = sortedEntries.isNotEmpty ? sortedEntries.last : null;
    final mostCommonMoodEntry = _resolveMostCommonMoodEntry(sortedEntries);

    return MonthlyMoodSummary(
      month: normalizedMonth,
      entries: sortedEntries,
      mostCommonMoodEntry: mostCommonMoodEntry,
      bestStreak: bestStreak,
      lastEntry: lastEntry,
    );
  }

  MoodEntry? _resolveMostCommonMoodEntry(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return null;
    }

    final countByMood = <String, int>{};
    for (final entry in entries) {
      countByMood[entry.mood] = (countByMood[entry.mood] ?? 0) + 1;
    }
    final maxCount =
        countByMood.values.fold<int>(0, (max, count) => count > max ? count : max);
    final tiedMoods = countByMood.entries
        .where((e) => e.value == maxCount)
        .map((e) => e.key)
        .toSet();

    MoodEntry? bestEntry;
    for (final entry in entries) {
      if (!tiedMoods.contains(entry.mood)) {
        continue;
      }
      if (bestEntry == null || entry.date.isAfter(bestEntry.date)) {
        bestEntry = entry;
      }
    }

    return bestEntry;
  }
}
