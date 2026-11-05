import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/insights/domain/services/trend_calculator.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_category.dart';

import '../../../../support/entry_fixtures.dart';

void main() {
  final today = DateTime(2026, 11, 4);

  test('seven days give one slot per day with a gap where there is no entry',
      () {
    final result = TrendCalculator.compute([
      entryOn(DateTime(2026, 11, 4), calm),
      entryOn(DateTime(2026, 11, 3), happy),
      entryOn(DateTime(2026, 11, 1), sad),
    ], TrendRange.days7, today);

    expect(result.points, hasLength(7));
    expect(result.points.first.start, DateTime(2026, 10, 29));
    expect(result.points.last.start, today);
    expect(result.points.where((p) => p.level != null), hasLength(3));
    expect(result.points[1].level, isNull); // Oct 30
    expect(result.points.last.category, MoodCategory.peaceful);
    expect(result.entryCount, 3);
  });

  test('levels come from the category: high 3, medium 2, low 1', () {
    final result = TrendCalculator.compute([
      entryOn(DateTime(2026, 11, 4), happy),
      entryOn(DateTime(2026, 11, 3), neutral),
      entryOn(DateTime(2026, 11, 2), sad),
    ], TrendRange.days7, today);

    final levels = result.points.map((p) => p.level).whereType<double>();
    expect(levels, [1.0, 2.0, 3.0]);
  });

  test('entries outside the range are ignored', () {
    final result = TrendCalculator.compute([
      entryOn(DateTime(2026, 11, 4), calm),
      entryOn(DateTime(2026, 10, 28), calm),
    ], TrendRange.days7, today);

    expect(result.entryCount, 1);
  });

  test('the 30 day range spans a month boundary day by day', () {
    final result = TrendCalculator.compute(
        [entryOn(DateTime(2026, 10, 6), calm)], TrendRange.days30, today);

    expect(result.points, hasLength(30));
    expect(result.points.first.start, DateTime(2026, 10, 6));
    expect(result.points.first.level, 3);
  });

  test('90 days draw one point per week with the average level', () {
    final result = TrendCalculator.compute([
      entryOn(DateTime(2026, 11, 4), happy), // 3
      entryOn(DateTime(2026, 11, 3), sad), // 1
    ], TrendRange.days90, today);

    expect(result.points, hasLength(13));
    final last = result.points.last;
    expect(last.level, 2.0);
    expect(result.points.where((p) => p.level == null), hasLength(12));
  });

  test('a week takes the most frequent category as its tint', () {
    final result = TrendCalculator.compute([
      entryOn(DateTime(2026, 11, 4), calm),
      entryOn(DateTime(2026, 11, 3), calm),
      entryOn(DateTime(2026, 11, 2), sad),
    ], TrendRange.days90, today);

    expect(result.points.last.category, MoodCategory.peaceful);
  });

  test('365 days give 53 weekly points', () {
    final result = TrendCalculator.compute(
        [entryOn(DateTime(2026, 11, 4), calm)], TrendRange.days365, today);

    expect(result.points, hasLength(53));
  });

  test('reports the most frequent category of the range', () {
    final result = TrendCalculator.compute([
      entryOn(DateTime(2026, 11, 4), calm),
      entryOn(DateTime(2026, 11, 3), calm),
      entryOn(DateTime(2026, 11, 2), sad),
    ], TrendRange.days7, today);

    expect(result.dominantCategory, MoodCategory.peaceful);
    expect(
      TrendCalculator.compute(const [], TrendRange.days7, today)
          .dominantCategory,
      isNull,
    );
  });

  test('fewer than two entries in the range is insufficient', () {
    final one = TrendCalculator.compute(
        [entryOn(DateTime(2026, 11, 4), calm)], TrendRange.days7, today);
    final two = TrendCalculator.compute([
      entryOn(DateTime(2026, 11, 4), calm),
      entryOn(DateTime(2026, 11, 3), calm),
    ], TrendRange.days7, today);

    expect(one.isInsufficient, isTrue);
    expect(two.isInsufficient, isFalse);
  });

  test('only 90 and 365 days require the subscription', () {
    expect(TrendRange.values.where((r) => r.requiresPremium),
        [TrendRange.days90, TrendRange.days365]);
  });
}
