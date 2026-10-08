import '../entities/mood_definition.dart';
import '../entities/mood_entry.dart';

/// Ordena los moods del carrusel de selección diaria.
///
/// Primero los moods desbloqueados por frecuencia de uso (descendente); el
/// empate, incluido 0 usos, conserva el orden del catálogo. Después los moods
/// bloqueados en el orden del catálogo. No usa `intensity` (ADR 0001).
class MoodPickerOrder {
  const MoodPickerOrder._();

  static List<MoodDefinition> sort(
    List<MoodEntry> entries, {
    required bool Function(String moodId) isUnlocked,
  }) {
    final usageByAssetPath = <String, int>{};
    for (final entry in entries) {
      usageByAssetPath[entry.mood] = (usageByAssetPath[entry.mood] ?? 0) + 1;
    }

    final unlocked = <MoodDefinition>[];
    final locked = <MoodDefinition>[];
    for (final mood in allMoodDefinitions) {
      (isUnlocked(mood.id) ? unlocked : locked).add(mood);
    }

    final catalogIndex = {
      for (var i = 0; i < unlocked.length; i++) unlocked[i].id: i,
    };
    unlocked.sort((a, b) {
      final byUsage = (usageByAssetPath[b.assetPath] ?? 0)
          .compareTo(usageByAssetPath[a.assetPath] ?? 0);
      return byUsage != 0
          ? byUsage
          : catalogIndex[a.id]!.compareTo(catalogIndex[b.id]!);
    });

    return [...unlocked, ...locked];
  }
}
