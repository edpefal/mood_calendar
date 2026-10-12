import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';

const _firstWaveMoodIds = [
  'affectionate',
  'hugging',
  'laughing',
  'sleepy',
  'sick',
  'hurt',
  'crying',
  'scared',
  'stressed',
];

void main() {
  test('catalog has 5 base and 14 premium moods', () {
    expect(allMoodDefinitions, hasLength(19));
    expect(baseMoodDefinitions, hasLength(5));
    expect(premiumMoodDefinitions, hasLength(14));
    expect(
      baseMoodDefinitions.every((mood) => mood.tier == MoodTier.base),
      isTrue,
    );
    expect(
      premiumMoodDefinitions.every((mood) => mood.tier == MoodTier.premium),
      isTrue,
    );
  });

  test('ids, asset paths and intensities are unique', () {
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
  });

  test('every asset path is derived from the mood id', () {
    for (final mood in allMoodDefinitions) {
      expect(mood.assetPath, 'assets/icon/${mood.id}.svg');
    }
  });

  test('every mood color is a MaterialColor', () {
    for (final mood in allMoodDefinitions) {
      expect(mood.color, isA<MaterialColor>(), reason: mood.id);
    }
  });

  test('first-wave moods are premium and follow the existing premium moods',
      () {
    final premiumIds = premiumMoodDefinitions.map((mood) => mood.id).toList();

    expect(premiumIds.skip(5), _firstWaveMoodIds);
    expect(premiumIds.take(5), [
      'anxious',
      'brave',
      'confident',
      'romantic',
      'shy',
    ]);
  });

  test('pack members share no color inside the same pack', () {
    final packs = [
      _firstWaveMoodIds.sublist(0, 3),
      _firstWaveMoodIds.sublist(3, 6),
      _firstWaveMoodIds.sublist(6, 9),
    ];
    for (final pack in packs) {
      final colors = pack
          .map((id) => allMoodDefinitions.firstWhere((m) => m.id == id).color)
          .toSet();
      expect(colors, hasLength(pack.length), reason: pack.join(','));
    }
  });
}
