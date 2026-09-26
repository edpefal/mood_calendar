import '../entities/monthly_mood_summary.dart';
import '../entities/mood_entry.dart';
import 'get_moods_for_month_usecase.dart';

class GetMonthlyMoodSummaryUseCase {
  final GetMoodsForMonthUseCase getMoodsForMonth;

  GetMonthlyMoodSummaryUseCase(this.getMoodsForMonth);

  Future<MonthlyMoodSummary> call(DateTime month) async {
    final normalizedMonth = DateTime(month.year, month.month);
    final entries = await getMoodsForMonth(normalizedMonth);
    final sortedEntries = [...entries]
      ..sort((a, b) => a.date.compareTo(b.date));

    final bestStreak = _calculateBestStreak(sortedEntries);
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

  int _calculateBestStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    int bestStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < entries.length; i++) {
      final previousDate = entries[i - 1].date;
      final currentDate = entries[i].date;
      final isConsecutive = currentDate.difference(previousDate).inDays == 1 &&
          currentDate.month == previousDate.month &&
          currentDate.year == previousDate.year;

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
