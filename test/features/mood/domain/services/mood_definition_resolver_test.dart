import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/mood/domain/services/mood_definition_resolver.dart';

void main() {
  group('MoodDefinitionResolver', () {
    test('resolves base mood by asset path', () {
      final mood = MoodDefinitionResolver.byAssetPath('assets/icon/calm.svg');

      expect(mood.id, 'calm');
      expect(mood.intensity, 2);
    });

    test('keeps base mood fallback for unknown paths', () {
      final mood = MoodDefinitionResolver.byAssetPath('missing.svg');

      expect(mood, baseMoodDefinitions.first);
    });

    test('returns legacy intensity from known mood path', () {
      final intensity =
          MoodDefinitionResolver.intensityFromMoodPath('assets/icon/angry.svg');

      expect(intensity, 5);
    });

    test('backgroundGradientForMood returns 2 distinct colors for every mood',
        () {
      for (final mood in allMoodDefinitions) {
        final gradient = MoodDefinitionResolver.backgroundGradientForMood(mood);

        expect(gradient.colors.length, 2);
        expect(gradient.colors[0], isNot(equals(gradient.colors[1])));
      }
    });
  });
}
