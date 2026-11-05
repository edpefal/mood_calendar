import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/insights/domain/services/year_pixels.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_category.dart';

import '../../../../support/entry_fixtures.dart';

void main() {
  final today = DateTime(2026, 11, 4);

  test('covers every day of the year, with leap years handled', () {
    expect(YearPixels.compute(const [], 2026, today), hasLength(365));
    expect(YearPixels.compute(const [], 2028, today), hasLength(366));
  });

  test('tints logged days, leaves the rest empty and marks the future', () {
    final days = YearPixels.compute([
      entryOn(DateTime(2026, 11, 4), calm),
      entryOn(DateTime(2026, 1, 1), sad),
    ], 2026, today);

    final jan1 = days.first;
    expect(jan1.category, MoodCategory.hard);
    expect(jan1.entry, isNotNull);

    final nov3 = days.firstWhere((d) => d.date == DateTime(2026, 11, 3));
    expect(nov3.category, isNull);
    expect(nov3.isFuture, isFalse);

    final nov4 = days.firstWhere((d) => d.date == today);
    expect(nov4.category, MoodCategory.peaceful);
    expect(nov4.isFuture, isFalse);

    expect(days.firstWhere((d) => d.date == DateTime(2026, 11, 5)).isFuture,
        isTrue);
  });

  test('ignores entries from other years', () {
    final days = YearPixels.compute(
        [entryOn(DateTime(2025, 12, 31), calm)], 2026, today);

    expect(days.where((d) => d.entry != null), isEmpty);
  });

  test('lists the years with entries and always the current one', () {
    final years = YearPixels.yearsWithEntries([
      entryOn(DateTime(2024, 5, 1), calm),
      entryOn(DateTime(2025, 5, 1), calm),
      entryOn(DateTime(2024, 6, 1), calm),
    ], today);

    expect(years, [2024, 2025, 2026]);
    expect(YearPixels.yearsWithEntries(const [], today), [2026]);
  });
}
