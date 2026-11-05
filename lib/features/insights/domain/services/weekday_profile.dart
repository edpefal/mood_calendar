import '../../../mood/domain/entities/mood_category.dart';
import '../../../mood/domain/entities/mood_entry.dart';
import '../../../mood/domain/services/entry_category.dart';
import 'insights_thresholds.dart';

class WeekdayStat {
  const WeekdayStat({
    required this.weekday,
    required this.level,
    required this.category,
    required this.count,
  });

  /// `DateTime.monday` (1) to `DateTime.sunday` (7).
  final int weekday;

  /// Average level, 1 (low) to 3 (high).
  final double level;

  /// Most frequent category on that weekday.
  final MoodCategory category;

  final int count;
}

class WeekdayProfileResult {
  const WeekdayProfileResult({required this.days, required this.entryCount});

  /// Index 0 is Monday. Null when the weekday has too few entries.
  final List<WeekdayStat?> days;

  final int entryCount;

  bool get isInsufficient =>
      entryCount < InsightsThresholds.minEntriesForWeekdayProfile;
}

/// Average mood level by day of the week, from the category's level
/// (ADR 0003), never from `intensity`.
class WeekdayProfile {
  const WeekdayProfile._();

  static WeekdayProfileResult compute(Iterable<MoodEntry> entries) {
    final byWeekday = List.generate(7, (_) => <MoodCategory>[]);
    var count = 0;
    for (final entry in entries) {
      final category = categoryOfEntry(entry);
      if (category == null) continue;
      byWeekday[entry.date.weekday - 1].add(category);
      count++;
    }

    final days = [
      for (var i = 0; i < 7; i++)
        byWeekday[i].length < InsightsThresholds.minEntriesPerWeekday
            ? null
            : _statFor(i + 1, byWeekday[i]),
    ];
    return WeekdayProfileResult(days: days, entryCount: count);
  }

  static WeekdayStat _statFor(int weekday, List<MoodCategory> categories) {
    final counts = <MoodCategory, int>{};
    var total = 0;
    for (final c in categories) {
      counts[c] = (counts[c] ?? 0) + 1;
      total += switch (c.level) {
        MoodLevel.high => 3,
        MoodLevel.medium => 2,
        MoodLevel.low => 1,
      };
    }
    final dominant = MoodCategory.values
        .where(counts.containsKey)
        .reduce((a, b) => counts[b]! > counts[a]! ? b : a);
    return WeekdayStat(
      weekday: weekday,
      level: total / categories.length,
      category: dominant,
      count: categories.length,
    );
  }
}
