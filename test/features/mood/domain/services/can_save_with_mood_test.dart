import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/mood/domain/entities/mood_definition.dart';
import 'package:mood_calendar/features/mood/domain/services/can_save_with_mood.dart';
import 'package:mood_calendar/features/mood/domain/services/mood_definition_resolver.dart';

void main() {
  final happy = MoodDefinitionResolver.byId('happy');
  final brave = MoodDefinitionResolver.byId('brave');
  final anxious = MoodDefinitionResolver.byId('anxious');

  test('a base mood can always be saved', () {
    expect(happy.tier, MoodTier.base);
    expect(
      canSaveWithMood(mood: happy, isUnlocked: true, savedMoodAssetPath: null),
      isTrue,
    );
  });

  test('an unlocked premium mood can be saved', () {
    expect(
      canSaveWithMood(mood: brave, isUnlocked: true, savedMoodAssetPath: null),
      isTrue,
    );
  });

  test('a locked premium mood cannot start a new entry', () {
    expect(
      canSaveWithMood(mood: brave, isUnlocked: false, savedMoodAssetPath: null),
      isFalse,
    );
  });

  test('a locked premium mood cannot replace the saved mood with another', () {
    expect(
      canSaveWithMood(
        mood: brave,
        isUnlocked: false,
        savedMoodAssetPath: happy.assetPath,
      ),
      isFalse,
    );
    expect(
      canSaveWithMood(
        mood: brave,
        isUnlocked: false,
        savedMoodAssetPath: anxious.assetPath,
      ),
      isFalse,
    );
  });

  test('editing only the note keeps the same lapsed premium mood', () {
    expect(
      canSaveWithMood(
        mood: brave,
        isUnlocked: false,
        savedMoodAssetPath: brave.assetPath,
      ),
      isTrue,
    );
  });
}
