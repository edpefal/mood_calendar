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

    final averageScore = sortedEntries.isEmpty
        ? 0.0
        : sortedEntries
                .map((e) => e.intensity)
                .fold<int>(0, (sum, value) => sum + value) /
            sortedEntries.length;

    final bestStreak = _calculateBestStreak(sortedEntries);
    final lastEntry = sortedEntries.isNotEmpty ? sortedEntries.last : null;
    final representativeAverageEntry =
        _resolveRepresentativeAverageEntry(sortedEntries, averageScore);

    return MonthlyMoodSummary(
      month: normalizedMonth,
      entries: sortedEntries,
      averageScore: averageScore,
      bestStreak: bestStreak,
      lastEntry: lastEntry,
      representativeAverageEntry: representativeAverageEntry,
    );
  }

  MoodEntry? _resolveRepresentativeAverageEntry(
    List<MoodEntry> entries,
    double averageScore,
  ) {
    if (entries.isEmpty) {
      return null;
    }

    MoodEntry? bestEntry;
    double? bestDistance;

    for (final entry in entries) {
      final distance = (entry.intensity - averageScore).abs();
      if (bestEntry == null ||
          distance < bestDistance! ||
          (distance == bestDistance && entry.date.isAfter(bestEntry.date))) {
        bestEntry = entry;
        bestDistance = distance;
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
