import '../entities/mood_category.dart';
import '../entities/mood_entry.dart';
import 'entry_category.dart';

class CategoryShare {
  const CategoryShare({
    required this.category,
    required this.count,
    required this.percent,
  });

  final MoodCategory category;
  final int count;

  /// Whole percent; the shares of one distribution add up to exactly 100.
  final int percent;
}

/// Share of the entries that falls in each category.
class CategoryDistribution {
  const CategoryDistribution._();

  /// Categories with at least one entry, the most frequent first (ties in the
  /// fixed category order). Empty when no entry has a known mood.
  static List<CategoryShare> compute(Iterable<MoodEntry> entries) {
    final counts = {for (final c in MoodCategory.values) c: 0};
    var total = 0;
    for (final entry in entries) {
      final category = categoryOfEntry(entry);
      if (category == null) continue;
      counts[category] = counts[category]! + 1;
      total++;
    }
    if (total == 0) return const [];

    // Largest remainder, so rounding never makes the shares miss 100.
    final percents = {
      for (final c in MoodCategory.values) c: counts[c]! * 100 ~/ total,
    };
    var missing = 100 - percents.values.fold(0, (a, b) => a + b);
    final byRemainder =
        MoodCategory.values.where((c) => counts[c]! > 0).toList()
          ..sort((a, b) {
            final byRest =
                (counts[b]! * 100 % total).compareTo(counts[a]! * 100 % total);
            return byRest != 0 ? byRest : a.index.compareTo(b.index);
          });
    for (final category in byRemainder) {
      if (missing == 0) break;
      percents[category] = percents[category]! + 1;
      missing--;
    }

    final shares = [
      for (final c in MoodCategory.values)
        if (counts[c]! > 0)
          CategoryShare(category: c, count: counts[c]!, percent: percents[c]!),
    ]..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        return byCount != 0
            ? byCount
            : a.category.index.compareTo(b.category.index);
      });
    return shares;
  }
}
