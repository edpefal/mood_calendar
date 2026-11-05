import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/theme/app_theme.dart';
import 'package:mood_calendar/core/theme/brand_colors.dart';
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

    for (final brightness in Brightness.values) {
      testWidgets('tints follow the category in the ${brightness.name} theme',
          (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(MaterialApp(
          theme: buildAppTheme(brightness),
          home: Builder(builder: (context) {
            captured = context;
            return const SizedBox();
          }),
        ));
        final palette = BrandPalette.of(captured);

        MoodTint tintOf(String id) => MoodDefinitionResolver.tintFor(
              captured,
              MoodDefinitionResolver.byId(id),
            );

        expect(tintOf('calm'), palette.peaceful);
        expect(tintOf('brave'), palette.positive);
        expect(tintOf('shy'), palette.neutral);
        expect(tintOf('sad'), palette.hard);
        expect(tintOf('angry'), palette.angry);
        expect(
          MoodDefinitionResolver.tintForMoodPath(
            captured,
            'assets/icon/crying.svg',
          ),
          palette.hard,
        );
      });

      testWidgets(
          'backgroundGradientForMood returns 2 distinct colors for every '
          'mood (${brightness.name})', (tester) async {
        late BuildContext captured;
        await tester.pumpWidget(MaterialApp(
          theme: buildAppTheme(brightness),
          home: Builder(builder: (context) {
            captured = context;
            return const SizedBox();
          }),
        ));

        for (final mood in allMoodDefinitions) {
          final gradient = MoodDefinitionResolver.backgroundGradientForMood(
            captured,
            mood,
          );

          expect(gradient.colors.length, 2);
          expect(gradient.colors[0], isNot(equals(gradient.colors[1])));
        }
      });
    }
  });
}
