import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/mood/domain/services/mood_definition_resolver.dart';

void main() {
  group('MoodDefinitionResolver', () {
    test('resolves premium mood by asset path', () {
      final mood = MoodDefinitionResolver.byAssetPath('assets/icon/shy.svg');

      expect(mood.id, 'shy');
      expect(mood.isPremium, isTrue);
      expect(mood.intensity, 2);
    });

    test('keeps free mood fallback for unknown paths', () {
      final mood = MoodDefinitionResolver.byAssetPath('missing.svg');

      expect(mood, freeMoodDefinitions.first);
    });

    test('returns legacy intensity from known mood path', () {
      final intensity =
          MoodDefinitionResolver.intensityFromMoodPath('assets/icon/angry.svg');

      expect(intensity, 5);
    });
  });
}
