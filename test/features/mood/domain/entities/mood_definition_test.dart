import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/theme/brand_colors.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_category.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';

const _premiumIds = [
  'laughing',
  'confident',
  'brave',
  'affectionate',
  'hugging',
  'romantic',
  'shy',
  'hurt',
];

const _movedToFreeIds = [
  'sleepy',
  'anxious',
  'stressed',
  'scared',
  'crying',
  'sick',
];

void main() {
  test('catalog has 19 moods: 11 base and 8 premium', () {
    expect(allMoodDefinitions, hasLength(19));
    expect(baseMoodDefinitions, hasLength(11));
    expect(premiumMoodDefinitions, hasLength(8));
    expect(
      baseMoodDefinitions.every((mood) => mood.tier == MoodTier.base),
      isTrue,
    );
    expect(
      premiumMoodDefinitions.every((mood) => mood.tier == MoodTier.premium),
      isTrue,
    );
  });

  test('the premium moods are exactly the eight expressive ones', () {
    expect(
      premiumMoodDefinitions.map((mood) => mood.id).toSet(),
      _premiumIds.toSet(),
    );
  });

  test('the six moods that used to be premium are now base', () {
    for (final id in _movedToFreeIds) {
      expect(
        allMoodDefinitions.firstWhere((mood) => mood.id == id).tier,
        MoodTier.base,
        reason: id,
      );
    }
  });

  test('ids, asset paths and intensities are unique and stable', () {
    expect(
      allMoodDefinitions.map((mood) => mood.id).toSet(),
      hasLength(allMoodDefinitions.length),
    );
    expect(
      allMoodDefinitions.map((mood) => mood.assetPath).toSet(),
      hasLength(allMoodDefinitions.length),
    );
    expect(
      allMoodDefinitions.map((mood) => mood.intensity).toSet(),
      hasLength(allMoodDefinitions.length),
    );
    // Intensity identifies saved entries; it must not move with the redesign.
    expect(
      {for (final mood in allMoodDefinitions) mood.id: mood.intensity},
      containsPair('happy', 1),
    );
    expect(
      {for (final mood in allMoodDefinitions) mood.id: mood.intensity},
      containsPair('hurt', 16),
    );
  });

  test('every asset path is derived from the mood id', () {
    for (final mood in allMoodDefinitions) {
      expect(mood.assetPath, 'assets/icon/${mood.id}.svg');
    }
  });

  group('categories', () {
    List<String> idsOf(MoodCategory category) => allMoodDefinitions
        .where((mood) => mood.category == category)
        .map((mood) => mood.id)
        .toList();

    test('membership and order within each category are fixed', () {
      expect(idsOf(MoodCategory.positive),
          ['happy', 'laughing', 'confident', 'brave']);
      expect(idsOf(MoodCategory.peaceful),
          ['calm', 'affectionate', 'hugging', 'romantic']);
      expect(idsOf(MoodCategory.neutral), ['neutral', 'sleepy', 'shy']);
      expect(idsOf(MoodCategory.hard), [
        'sad',
        'angry',
        'anxious',
        'stressed',
        'scared',
        'crying',
        'sick',
        'hurt',
      ]);
    });

    test('the catalog list is already in screen order', () {
      final categoryIndexes = allMoodDefinitions
          .map((mood) => MoodCategory.values.indexOf(mood.category))
          .toList();

      expect(categoryIndexes, [...categoryIndexes]..sort());
    });

    test('moodDefinitionsByCategory groups every mood once, in order', () {
      final groups = moodDefinitionsByCategory();

      expect(groups.map((group) => group.category), MoodCategory.values);
      expect(
        groups.expand((group) => group.moods).map((mood) => mood.id),
        allMoodDefinitions.map((mood) => mood.id),
      );
    });

    test('category and tier are independent', () {
      final brave = allMoodDefinitions.firstWhere((m) => m.id == 'brave');
      final happy = allMoodDefinitions.firstWhere((m) => m.id == 'happy');

      expect(brave.tier, MoodTier.premium);
      expect(happy.tier, MoodTier.base);
      expect(brave.category, happy.category);
    });

    test('levels come from the category: high, high, medium, low', () {
      expect(MoodCategory.positive.level, MoodLevel.high);
      expect(MoodCategory.peaceful.level, MoodLevel.high);
      expect(MoodCategory.neutral.level, MoodLevel.medium);
      expect(MoodCategory.hard.level, MoodLevel.low);

      final shy = allMoodDefinitions.firstWhere((m) => m.id == 'shy');
      final crying = allMoodDefinitions.firstWhere((m) => m.id == 'crying');
      expect(shy.level, MoodLevel.medium);
      expect(crying.level, MoodLevel.low);
    });

    test('the level never depends on intensity', () {
      final byCategory = <MoodCategory, Set<MoodLevel>>{};
      for (final mood in allMoodDefinitions) {
        byCategory.putIfAbsent(mood.category, () => {}).add(mood.level);
      }

      for (final levels in byCategory.values) {
        expect(levels, hasLength(1));
      }
    });

    test('the tint is the category tone, except angry which is red', () {
      for (final mood in allMoodDefinitions) {
        expect(
          mood.tone,
          mood.id == 'angry' ? MoodTone.angry : mood.category.tone,
          reason: mood.id,
        );
      }
    });
  });
}
