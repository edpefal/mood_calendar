import 'package:flutter/material.dart';

import '../../../../core/theme/brand_colors.dart';
import '../entities/mood_definition.dart';

class MoodDefinitionResolver {
  static MoodDefinition byId(String id) {
    return allMoodDefinitions.firstWhere(
      (definition) => definition.id == id,
      orElse: () => allMoodDefinitions.first,
    );
  }

  static MoodDefinition byAssetPath(String assetPath) {
    return allMoodDefinitions.firstWhere(
      (definition) => definition.assetPath == assetPath,
      orElse: () => allMoodDefinitions.first,
    );
  }

  static MoodDefinition byIntensity(int intensity) {
    return allMoodDefinitions.firstWhere(
      (definition) => definition.intensity == intensity,
      orElse: () => byId('angry'),
    );
  }

  static int? intensityFromMoodPath(String assetPath) {
    final match =
        allMoodDefinitions.where((mood) => mood.assetPath == assetPath);
    if (match.isEmpty) {
      return null;
    }
    return match.first.intensity;
  }

  /// The tint (fill and selection ring) of a mood in the current theme.
  static MoodTint tintFor(BuildContext context, MoodDefinition mood) =>
      BrandPalette.of(context).tint(mood.tone);

  static MoodTint tintForMoodPath(BuildContext context, String assetPath) =>
      tintFor(context, byAssetPath(assetPath));

  /// Soft gradient for cards and backgrounds tied to a mood: the tint of its
  /// category fading toward the screen background.
  static LinearGradient backgroundGradientForMood(
    BuildContext context,
    MoodDefinition mood,
  ) {
    final palette = BrandPalette.of(context);
    final fill = palette.tint(mood.tone).fill;
    return LinearGradient(
      colors: [fill, Color.lerp(fill, palette.background, 0.5)!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
