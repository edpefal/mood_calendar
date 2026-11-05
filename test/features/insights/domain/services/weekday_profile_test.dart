import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/insights/domain/services/weekday_profile.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_category.dart';

import '../../../../support/entry_fixtures.dart';

void main() {
  // Nov 2, 2026 is a Monday.
  final monday = DateTime(2026, 11, 2);

  test('averages the level and picks the most frequent category per weekday',
      () {
    final entries = [
      entryOn(monday, happy),
      entryOn(monday.add(const Duration(days: 7)), calm),
      entryOn(monday.add(const Duration(days: 14)), sad),
      // Pad the rest of the week so the card has data.
      for (var d = 1; d < 7; d++) ...[
        entryOn(monday.add(Duration(days: d)), calm),
        entryOn(monday.add(Duration(days: d + 7)), calm),
      ],
    ];

    final result = WeekdayProfile.compute(entries);

    expect(result.isInsufficient, isFalse);
    final mondayStat = result.days[0]!;
    expect(mondayStat.weekday, DateTime.monday);
    expect(mondayStat.count, 3);
    expect(mondayStat.level, closeTo((3 + 3 + 1) / 3, 1e-9));
    expect(mondayStat.category, MoodCategory.positive); // tie, fixed order
  });

  test('a weekday with a single entry stays empty', () {
    final entries = [
      for (var week = 0; week < 3; week++)
        for (var d = 1; d < 7; d++)
          entryOn(monday.add(Duration(days: d + week * 7)), calm),
      entryOn(monday, calm),
    ];

    final result = WeekdayProfile.compute(entries);

    expect(result.days[0], isNull);
    expect(result.days[1], isNotNull);
  });

  test('fewer than 14 entries is insufficient', () {
    final nine = [
      for (var d = 0; d < 9; d++) entryOn(monday.add(Duration(days: d)), calm),
    ];
    final fourteen = [
      for (var d = 0; d < 14; d++) entryOn(monday.add(Duration(days: d)), calm),
    ];

    expect(WeekdayProfile.compute(nine).isInsufficient, isTrue);
    expect(WeekdayProfile.compute(fourteen).isInsufficient, isFalse);
  });
}
