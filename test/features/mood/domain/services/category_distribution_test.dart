import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/services/category_distribution.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_category.dart';

import '../../../../support/entry_fixtures.dart';

void main() {
  test('two peaceful and one positive give 67% and 33%', () {
    final shares = CategoryDistribution.compute([
      entryOn(DateTime(2026, 11, 1), calm),
      entryOn(DateTime(2026, 11, 2), calm),
      entryOn(DateTime(2026, 11, 3), happy),
    ]);

    expect(shares.map((s) => s.category),
        [MoodCategory.peaceful, MoodCategory.positive]);
    expect(shares.map((s) => s.percent), [67, 33]);
  });

  test('the percentages always add up to 100', () {
    final shares = CategoryDistribution.compute([
      entryOn(DateTime(2026, 11, 1), calm),
      entryOn(DateTime(2026, 11, 2), happy),
      entryOn(DateTime(2026, 11, 3), sad),
    ]);

    expect(shares.fold<int>(0, (sum, s) => sum + s.percent), 100);
  });

  test('categories without entries are left out', () {
    final shares = CategoryDistribution.compute([
      entryOn(DateTime(2026, 11, 1), sad),
    ]);

    expect(shares.single.category, MoodCategory.hard);
    expect(shares.single.percent, 100);
  });

  test('ties follow the fixed category order', () {
    final shares = CategoryDistribution.compute([
      entryOn(DateTime(2026, 11, 1), sad),
      entryOn(DateTime(2026, 11, 2), happy),
    ]);

    expect(shares.map((s) => s.category),
        [MoodCategory.positive, MoodCategory.hard]);
  });

  test('an empty month and unknown moods give no shares', () {
    expect(CategoryDistribution.compute(const []), isEmpty);
    expect(
      CategoryDistribution.compute([
        entryOn(DateTime(2026, 11, 1), 'assets/icon/removed.svg'),
      ]),
      isEmpty,
    );
  });
}
