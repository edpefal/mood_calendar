import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/services/category_distribution.dart';
import 'package:mood_calendar/features/insights/domain/services/trend_calculator.dart';
import 'package:mood_calendar/features/insights/domain/services/weekday_profile.dart';
import 'package:mood_calendar/features/insights/domain/services/year_pixels.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_entry.dart';

import '../../../../support/entry_fixtures.dart';

/// ADR 0003: the score comes from the category, never from `intensity`. The
/// same entries with wildly different intensities must give the same result.
void main() {
  final today = DateTime(2026, 11, 14);
  final moods = [happy, calm, neutral, sad];

  List<MoodEntry> entries(int Function(int i) intensity) => [
        for (var i = 0; i < 20; i++)
          entryOn(DateTime(2026, 11, 14 - i), moods[i % 4],
              intensity: intensity(i)),
      ];

  final low = entries((_) => 1);
  final scrambled = entries((i) => 100 - i * 7);

  test('distribution ignores intensity', () {
    List<(Object, int, int)> view(List<MoodEntry> e) => [
          for (final s in CategoryDistribution.compute(e))
            (s.category, s.count, s.percent),
        ];
    expect(view(scrambled), view(low));
  });

  test('trend ignores intensity', () {
    for (final range in TrendRange.values) {
      List<(double?, Object?)> view(List<MoodEntry> e) => [
            for (final p in TrendCalculator.compute(e, range, today).points)
              (p.level, p.category),
          ];
      expect(view(scrambled), view(low), reason: '$range');
    }
  });

  test('weekday profile ignores intensity', () {
    List<(double, Object)?> view(List<MoodEntry> e) => [
          for (final d in WeekdayProfile.compute(e).days)
            d == null ? null : (d.level, d.category),
        ];
    expect(view(scrambled), view(low));
  });

  test('year pixels ignore intensity', () {
    List<Object?> view(List<MoodEntry> e) =>
        [for (final d in YearPixels.compute(e, 2026, today)) d.category];
    expect(view(scrambled), view(low));
  });
}
