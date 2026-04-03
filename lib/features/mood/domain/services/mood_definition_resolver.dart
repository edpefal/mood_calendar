import 'package:flutter/material.dart';

import '../entities/mood_definition.dart';

class MoodDefinitionResolver {
  static MoodDefinition byId(String id) {
    return allMoodDefinitions.firstWhere(
      (definition) => definition.id == id,
      orElse: () => freeMoodDefinitions.first,
    );
  }

  static MoodDefinition byAssetPath(String assetPath) {
    return allMoodDefinitions.firstWhere(
      (definition) => definition.assetPath == assetPath,
      orElse: () => freeMoodDefinitions.first,
    );
  }

  static MoodDefinition byIntensity(int intensity) {
    return allMoodDefinitions.firstWhere(
      (definition) =>
          definition.intensity == intensity && !definition.isPremium,
      orElse: () => freeMoodDefinitions.last,
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

  static String moodPathForScore(double score) {
    if (score <= 1.5) return byIntensity(1).assetPath;
    if (score <= 2.5) return byIntensity(2).assetPath;
    if (score <= 3.5) return byIntensity(3).assetPath;
    if (score <= 4.5) return byIntensity(4).assetPath;
    return byIntensity(5).assetPath;
  }

  static Color colorForMoodPath(String assetPath) =>
      byAssetPath(assetPath).color;

  static LinearGradient backgroundGradientForMood(MoodDefinition mood) {
    switch (mood.id) {
      case 'happy':
      case 'brave':
      case 'confident':
        return const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'calm':
      case 'shy':
      case 'romantic':
        return const LinearGradient(
          colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'neutral':
        return const LinearGradient(
          colors: [Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'sad':
      case 'anxious':
        return const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'angry':
        return const LinearGradient(
          colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
