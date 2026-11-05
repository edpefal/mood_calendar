import '../../../mood/domain/entities/mood_category.dart';
import '../../../mood/domain/entities/mood_entry.dart';
import '../../../mood/domain/services/entry_category.dart';

/// One day of the Year in Pixels grid.
class PixelDay {
  const PixelDay({
    required this.date,
    required this.entry,
    required this.category,
    required this.isFuture,
  });

  final DateTime date;

  /// The day's entry, or null when there is none.
  final MoodEntry? entry;

  /// Category that tints the pixel; null for an empty day.
  final MoodCategory? category;

  /// After today: drawn inert.
  final bool isFuture;
}

class YearPixels {
  const YearPixels._();

  /// Every day of [year] in order, with its entry when it has one.
  static List<PixelDay> compute(
    Iterable<MoodEntry> entries,
    int year,
    DateTime today,
  ) {
    final byDay = <DateTime, MoodEntry>{};
    for (final entry in entries) {
      if (entry.date.year == year) byDay[dayOf(entry.date)] = entry;
    }
    final end = dayOf(today);
    final days = <PixelDay>[];
    for (var date = DateTime(year);
        date.year == year;
        date = DateTime(year, date.month, date.day + 1)) {
      final entry = byDay[date];
      days.add(PixelDay(
        date: date,
        entry: entry,
        category: entry == null ? null : categoryOfEntry(entry),
        isFuture: date.isAfter(end),
      ));
    }
    return days;
  }

  /// Years that have at least one entry, oldest first, always including the
  /// year of [today] so the current year can be shown while it is empty.
  static List<int> yearsWithEntries(
      Iterable<MoodEntry> entries, DateTime today) {
    final years = {today.year, for (final e in entries) e.date.year}.toList()
      ..sort();
    return years;
  }
}
