import '../../../../core/theme/brand_colors.dart';

/// Three-level score a category carries for the analyses that need a number
/// (ADR 0003). A mood inherits it from its category and never has its own.
enum MoodLevel { high, medium, low }

/// The four groups every mood belongs to, in the order the app lists them.
/// The category decides the mood's order on screen, its tint and its level;
/// it is independent of the mood's tier and of its `intensity`.
enum MoodCategory {
  positive(MoodLevel.high, MoodTone.positive),
  peaceful(MoodLevel.high, MoodTone.peaceful),
  neutral(MoodLevel.medium, MoodTone.neutral),
  hard(MoodLevel.low, MoodTone.hard);

  const MoodCategory(this.level, this.tone);

  final MoodLevel level;

  /// Tint of the category (a mood may override it, e.g. `angry`).
  final MoodTone tone;
}
