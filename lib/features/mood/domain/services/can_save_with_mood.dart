import '../entities/mood_definition.dart';

/// Si se puede guardar la entrada del día con [mood].
///
/// Un mood desbloqueado siempre se puede guardar. Uno bloqueado solo si es el
/// mismo que ya tenía la entrada de esa fecha ([savedMoodAssetPath]): así quien
/// dejó de pagar sigue pudiendo editar la nota de un día antiguo, pero no puede
/// elegir otro mood premium ni crear entradas nuevas con uno.
bool canSaveWithMood({
  required MoodDefinition mood,
  required bool isUnlocked,
  required String? savedMoodAssetPath,
}) {
  if (mood.tier == MoodTier.base || isUnlocked) {
    return true;
  }
  return savedMoodAssetPath != null && savedMoodAssetPath == mood.assetPath;
}
