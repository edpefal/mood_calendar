import 'package:flutter/material.dart';

class MoodDefinition {
  final String id;
  final String label;
  final String assetPath;
  final Color color;
  final int intensity;

  const MoodDefinition({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.color,
    required this.intensity,
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

const List<MoodDefinition> allMoodDefinitions = freeMoodDefinitions;
