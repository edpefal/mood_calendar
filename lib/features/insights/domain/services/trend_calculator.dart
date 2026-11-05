import '../../../mood/domain/entities/mood_category.dart';
import '../../../mood/domain/entities/mood_entry.dart';
import '../../../mood/domain/services/entry_category.dart';
import 'insights_thresholds.dart';

/// Ranges of the trend card, all ending today.
enum TrendRange {
  days7(7),
  days30(30),
  days90(90),
  days365(365);

  const TrendRange(this.days);

  final int days;

  /// 7 and 30 days draw one point per day; the longer ones one per week.
  bool get isDaily => days <= 30;

  /// Free users get 7 and 30 days; 90 and 365 need the subscription.
  bool get requiresPremium => !isDaily;
}

/// One point of the trend. [level] is null for a gap: a day (or a week) with
/// no entry.
class TrendPoint {
  const TrendPoint({
    required this.start,
    required this.level,
    required this.category,
  });

  /// First day the point covers (the day itself for daily ranges).
  final DateTime start;

  /// 1 (low) to 3 (high); a weekly point is the average of its entries.
  final double? level;

  /// Category that tints the point (the most frequent one in a week).
  final MoodCategory? category;
}

class TrendResult {
  const TrendResult({
    required this.points,
    required this.entryCount,
    this.dominantCategory,
  });

  final List<TrendPoint> points;

  /// The most frequent category among the entries in the range (ties go to
  /// the earlier one in the fixed order); null when there are none.
  final MoodCategory? dominantCategory;

  /// Entries with a known mood inside the range.
  final int entryCount;

  bool get isInsufficient =>
      entryCount < InsightsThresholds.minEntriesPerTrendRange;
}

/// Mood level over time. The number comes from the category's level
/// (ADR 0003), never from `intensity`.
class TrendCalculator {
  const TrendCalculator._();

  /// Weekly ranges are rounded up to whole weeks (90 days is 13 weeks).
  static TrendResult compute(
    Iterable<MoodEntry> entries,
    TrendRange range,
    DateTime today,
  ) {
    final end = dayOf(today);
    final slots = range.isDaily ? range.days : (range.days / 7).ceil();
    final slotLength = range.isDaily ? 1 : 7;
    final first =
        DateTime(end.year, end.month, end.day - (slots * slotLength - 1));

    final buckets = List.generate(slots, (_) => <MoodCategory>[]);
    final totals = <MoodCategory, int>{};
    var count = 0;
    for (final entry in entries) {
      final category = categoryOfEntry(entry);
      if (category == null) continue;
      final day = dayOf(entry.date);
      if (day.isBefore(first) || day.isAfter(end)) continue;
      final index = _daysBetween(first, day) ~/ slotLength;
      buckets[index].add(category);
      totals[category] = (totals[category] ?? 0) + 1;
      count++;
    }

    final points = [
      for (var i = 0; i < slots; i++)
        _pointFor(
          DateTime(first.year, first.month, first.day + i * slotLength),
          buckets[i],
        ),
    ];
    final dominant = totals.isEmpty
        ? null
        : MoodCategory.values
            .where(totals.containsKey)
            .reduce((a, b) => totals[b]! > totals[a]! ? b : a);
    return TrendResult(
      points: points,
      entryCount: count,
      dominantCategory: dominant,
    );
  }

  static TrendPoint _pointFor(DateTime start, List<MoodCategory> categories) {
    if (categories.isEmpty) {
      return TrendPoint(start: start, level: null, category: null);
    }
    final total = categories.fold<int>(0, (sum, c) => sum + _score(c));
    final counts = <MoodCategory, int>{};
    for (final c in categories) {
      counts[c] = (counts[c] ?? 0) + 1;
    }
    final dominant = MoodCategory.values
        .where(counts.containsKey)
        .reduce((a, b) => counts[b]! > counts[a]! ? b : a);
    return TrendPoint(
      start: start,
      level: total / categories.length,
      category: dominant,
    );
  }

  /// The only place a level becomes a number.
  static int _score(MoodCategory category) => switch (category.level) {
        MoodLevel.high => 3,
        MoodLevel.medium => 2,
        MoodLevel.low => 1,
      };

  static int _daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays;
}
