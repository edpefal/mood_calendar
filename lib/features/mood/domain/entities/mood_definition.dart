import '../../../../core/theme/brand_colors.dart';
import 'mood_category.dart';

enum MoodTier { base, premium }

class MoodDefinition {
  final String id;
  final String label;
  final String assetPath;
  final MoodCategory category;

  /// Only for a mood whose tint is not its category's (today, `angry`).
  final MoodTone? toneOverride;
  final int intensity;
  final MoodTier tier;

  const MoodDefinition({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.category,
    required this.intensity,
    required this.tier,
    this.toneOverride,
  });

  /// Tint used to paint the mood: its category's, unless it overrides it.
  MoodTone get tone => toneOverride ?? category.tone;

  /// Score for the analyses; always the category's (ADR 0003).
  MoodLevel get level => category.level;
}

/// The whole catalog in the fixed on-screen order: categories as in
/// [MoodCategory], and within each category the order listed here. The order
/// never depends on usage, `unlocked` or `intensity`. A new mood must declare
/// its category (the field is required).
const List<MoodDefinition> allMoodDefinitions = [
  MoodDefinition(
    id: 'happy',
    label: 'Happy',
    assetPath: 'assets/icon/happy.svg',
    category: MoodCategory.positive,
    intensity: 1,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'laughing',
    label: 'Laughing',
    assetPath: 'assets/icon/laughing.svg',
    category: MoodCategory.positive,
    intensity: 13,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'confident',
    label: 'Confident',
    assetPath: 'assets/icon/confident.svg',
    category: MoodCategory.positive,
    intensity: 8,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'brave',
    label: 'Brave',
    assetPath: 'assets/icon/brave.svg',
    category: MoodCategory.positive,
    intensity: 7,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'calm',
    label: 'Calm',
    assetPath: 'assets/icon/calm.svg',
    category: MoodCategory.peaceful,
    intensity: 2,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'affectionate',
    label: 'Affectionate',
    assetPath: 'assets/icon/affectionate.svg',
    category: MoodCategory.peaceful,
    intensity: 11,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'hugging',
    label: 'Hugging',
    assetPath: 'assets/icon/hugging.svg',
    category: MoodCategory.peaceful,
    intensity: 12,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'romantic',
    label: 'Romantic',
    assetPath: 'assets/icon/romantic.svg',
    category: MoodCategory.peaceful,
    intensity: 9,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'neutral',
    label: 'Neutral',
    assetPath: 'assets/icon/neutral.svg',
    category: MoodCategory.neutral,
    intensity: 3,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'sleepy',
    label: 'Sleepy',
    assetPath: 'assets/icon/sleepy.svg',
    category: MoodCategory.neutral,
    intensity: 14,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'shy',
    label: 'Shy',
    assetPath: 'assets/icon/shy.svg',
    category: MoodCategory.neutral,
    intensity: 10,
    tier: MoodTier.premium,
  ),
  MoodDefinition(
    id: 'sad',
    label: 'Sad',
    assetPath: 'assets/icon/sad.svg',
    category: MoodCategory.hard,
    intensity: 4,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'angry',
    label: 'Angry',
    assetPath: 'assets/icon/angry.svg',
    category: MoodCategory.hard,
    toneOverride: MoodTone.angry,
    intensity: 5,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'anxious',
    label: 'Anxious',
    assetPath: 'assets/icon/anxious.svg',
    category: MoodCategory.hard,
    intensity: 6,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'stressed',
    label: 'Stressed',
    assetPath: 'assets/icon/stressed.svg',
    category: MoodCategory.hard,
    intensity: 19,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'scared',
    label: 'Scared',
    assetPath: 'assets/icon/scared.svg',
    category: MoodCategory.hard,
    intensity: 18,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'crying',
    label: 'Crying',
    assetPath: 'assets/icon/crying.svg',
    category: MoodCategory.hard,
    intensity: 17,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'sick',
    label: 'Sick',
    assetPath: 'assets/icon/sick.svg',
    category: MoodCategory.hard,
    intensity: 15,
    tier: MoodTier.base,
  ),
  MoodDefinition(
    id: 'hurt',
    label: 'Hurt',
    assetPath: 'assets/icon/hurt.svg',
    category: MoodCategory.hard,
    intensity: 16,
    tier: MoodTier.premium,
  ),
];

/// The free moods, in catalog order.
final List<MoodDefinition> baseMoodDefinitions = List.unmodifiable(
  allMoodDefinitions.where((mood) => mood.tier == MoodTier.base),
);

/// The moods a subscription unlocks, in catalog order.
final List<MoodDefinition> premiumMoodDefinitions = List.unmodifiable(
  allMoodDefinitions.where((mood) => mood.tier == MoodTier.premium),
);

/// The catalog grouped by category, in category order.
List<({MoodCategory category, List<MoodDefinition> moods})>
    moodDefinitionsByCategory() => [
          for (final category in MoodCategory.values)
            (
              category: category,
              moods: [
                for (final mood in allMoodDefinitions)
                  if (mood.category == category) mood,
              ],
            ),
        ];
