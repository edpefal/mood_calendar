import '../entities/mood_category.dart';
import '../entities/mood_definition.dart';
import '../entities/mood_entry.dart';

/// The catalog mood of an entry, or null when its stored path is unknown.
/// Unknown moods are left out of the analyses rather than counted as another
/// mood. Only the mood path is read: never `intensity` (ADR 0003).
MoodDefinition? definitionOfEntry(MoodEntry entry) {
  for (final definition in allMoodDefinitions) {
    if (definition.assetPath == entry.mood) return definition;
  }
  return null;
}

MoodCategory? categoryOfEntry(MoodEntry entry) =>
    definitionOfEntry(entry)?.category;

DateTime dayOf(DateTime date) => DateTime(date.year, date.month, date.day);
