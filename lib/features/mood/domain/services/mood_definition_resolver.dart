import 'package:flutter/material.dart';

import '../entities/mood_definition.dart';

class MoodDefinitionResolver {
  static MoodDefinition byId(String id) {
    return allMoodDefinitions.firstWhere(
      (definition) => definition.id == id,
      orElse: () => baseMoodDefinitions.first,
    );
  }

  static MoodDefinition byAssetPath(String assetPath) {
    return allMoodDefinitions.firstWhere(
      (definition) => definition.assetPath == assetPath,
      orElse: () => baseMoodDefinitions.first,
    );
  }

  static MoodDefinition byIntensity(int intensity) {
    return allMoodDefinitions.firstWhere(
      (definition) => definition.intensity == intensity,
      orElse: () => baseMoodDefinitions.last,
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

  static Color colorForMoodPath(String assetPath) =>
      byAssetPath(assetPath).color;

  static LinearGradient backgroundGradientForMood(MoodDefinition mood) {
    final swatch = mood.color as MaterialColor;
    return LinearGradient(
      colors: [swatch.shade50, swatch.shade200],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
