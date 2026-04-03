import 'package:flutter/material.dart';

class MoodDefinition {
  final String id;
  final String label;
  final String assetPath;
  final Color color;
  final int intensity;
  final bool isPremium;
  final String? productId;
  final List<String> packIds;

  const MoodDefinition({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.color,
    required this.intensity,
    this.isPremium = false,
    this.productId,
    this.packIds = const [],
  });
}

const List<MoodDefinition> freeMoodDefinitions = [
  MoodDefinition(
    id: 'happy',
    label: 'Happy',
    assetPath: 'assets/icon/happy.svg',
    color: Colors.green,
    intensity: 1,
  ),
  MoodDefinition(
    id: 'calm',
    label: 'Calm',
    assetPath: 'assets/icon/calm.svg',
    color: Colors.blue,
    intensity: 2,
  ),
  MoodDefinition(
    id: 'neutral',
    label: 'Neutral',
    assetPath: 'assets/icon/neutral.svg',
    color: Colors.grey,
    intensity: 3,
  ),
  MoodDefinition(
    id: 'sad',
    label: 'Sad',
    assetPath: 'assets/icon/sad.svg',
    color: Colors.orange,
    intensity: 4,
  ),
  MoodDefinition(
    id: 'angry',
    label: 'Angry',
    assetPath: 'assets/icon/angry.svg',
    color: Colors.red,
    intensity: 5,
  ),
];

const List<MoodDefinition> premiumMoodDefinitions = [
  MoodDefinition(
    id: 'shy',
    label: 'Shy',
    assetPath: 'assets/icon/shy.svg',
    color: Color(0xFF8E7DBE),
    intensity: 2,
    isPremium: true,
    productId: 'mood_shy_unlock',
    packIds: ['soft_emotions_pack'],
  ),
  MoodDefinition(
    id: 'brave',
    label: 'Brave',
    assetPath: 'assets/icon/brave.svg',
    color: Color(0xFF00897B),
    intensity: 1,
    isPremium: true,
    productId: 'mood_brave_unlock',
    packIds: ['confidence_pack'],
  ),
  MoodDefinition(
    id: 'confident',
    label: 'Confident',
    assetPath: 'assets/icon/confident.svg',
    color: Color(0xFF7B1FA2),
    intensity: 1,
    isPremium: true,
    productId: 'mood_confident_unlock',
    packIds: ['confidence_pack'],
  ),
  MoodDefinition(
    id: 'romantic',
    label: 'Romantic',
    assetPath: 'assets/icon/romantic.svg',
    color: Color(0xFFE91E63),
    intensity: 2,
    isPremium: true,
    productId: 'mood_romantic_unlock',
    packIds: ['soft_emotions_pack'],
  ),
  MoodDefinition(
    id: 'anxious',
    label: 'Anxious',
    assetPath: 'assets/icon/anxious.svg',
    color: Color(0xFF6D4C41),
    intensity: 4,
    isPremium: true,
    productId: 'mood_anxious_unlock',
    packIds: ['soft_emotions_pack'],
  ),
];

const List<MoodDefinition> allMoodDefinitions = [
  ...freeMoodDefinitions,
  ...premiumMoodDefinitions,
];
