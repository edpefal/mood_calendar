import 'package:flutter/material.dart';

enum MoodTier { base, premium }

class MoodDefinition {
  final String id;
  final String label;
  final String assetPath;
  final Color color;
  final int intensity;
  final MoodTier tier;

  const MoodDefinition({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.color,
    required this.intensity,
    required this.tier,
  });
}

const List<MoodDefinition> baseMoodDefinitions = [
  MoodDefinition(
    id: 'happy',
    label: 'Happy',
    assetPath: 'assets/icon/happy.svg',
    color: Colors.green,
    intensity: 1,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'calm',
    label: 'Calm',
    assetPath: 'assets/icon/calm.svg',
    color: Colors.blue,
    intensity: 2,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'neutral',
    label: 'Neutral',
    assetPath: 'assets/icon/neutral.svg',
    color: Colors.grey,
    intensity: 3,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'sad',
    label: 'Sad',
    assetPath: 'assets/icon/sad.svg',
    color: Colors.orange,
    intensity: 4,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'angry',
    label: 'Angry',
    assetPath: 'assets/icon/angry.svg',
    color: Colors.red,
    intensity: 5,
    tier: MoodTier.base,
  ),
];

const List<MoodDefinition> premiumMoodDefinitions = [
  MoodDefinition(
    id: 'anxious',
    label: 'Anxious',
    assetPath: 'assets/icon/anxious.svg',
    color: Colors.teal,
    intensity: 6,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'brave',
    label: 'Brave',
    assetPath: 'assets/icon/brave.svg',
    color: Colors.indigo,
    intensity: 7,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'confident',
    label: 'Confident',
    assetPath: 'assets/icon/confident.svg',
    color: Colors.amber,
    intensity: 8,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'romantic',
    label: 'Romantic',
    assetPath: 'assets/icon/romantic.svg',
    color: Colors.pink,
    intensity: 9,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'shy',
    label: 'Shy',
    assetPath: 'assets/icon/shy.svg',
    color: Colors.brown,
    intensity: 10,
    tier: MoodTier.premium,
  ),
];

const List<MoodDefinition> allMoodDefinitions = [
  ...baseMoodDefinitions,
  ...premiumMoodDefinitions,
];
