import 'package:flutter/material.dart';

/// Tint of a mood cell, card or background, and the ring that marks it as
/// selected. Mood tints come from the mood's category (`MoodTone`), never
/// from the mood itself, except for `angry`.
@immutable
class MoodTint {
  const MoodTint({required this.fill, required this.ring});

  final Color fill;
  final Color ring;

  static MoodTint lerp(MoodTint a, MoodTint b, double t) => MoodTint(
        fill: Color.lerp(a.fill, b.fill, t)!,
        ring: Color.lerp(a.ring, b.ring, t)!,
      );
}

/// The five tints of the app: one per mood category plus the red of `angry`.
enum MoodTone { positive, peaceful, neutral, hard, angry }

/// Every color of the visual system, in a light and a dark variant. Read it
/// with `BrandPalette.of(context)`; never use a color literal in a widget.
@immutable
class BrandPalette extends ThemeExtension<BrandPalette> {
  const BrandPalette({
    required this.brightness,
    required this.ink,
    required this.onInk,
    required this.text,
    required this.textSecondary,
    required this.background,
    required this.mesh,
    required this.glassFill,
    required this.glassBorder,
    required this.glassOpaque,
    required this.shadow,
    required this.tabBar,
    required this.tabBarBorder,
    required this.onTabBar,
    required this.onTabBarMuted,
    required this.logGradient,
    required this.onLogGradient,
    required this.positive,
    required this.peaceful,
    required this.neutral,
    required this.hard,
    required this.angry,
    required this.danger,
  });

  final Brightness brightness;

  /// Primary actions: the filled pill buttons and active controls.
  final Color ink;
  final Color onInk;

  /// Body text and the quieter text of captions and hints.
  final Color text;
  final Color textSecondary;

  /// Base color of the screen background and the four pastel blobs of the
  /// mesh painted over it (top-left, top-right, bottom-right, bottom-left).
  final Color background;
  final List<Color> mesh;

  /// Glass cards: translucent fill, border, and the opaque fill used instead
  /// when the system asks to reduce transparency.
  final Color glassFill;
  final Color glassBorder;
  final Color glassOpaque;
  final Color shadow;

  /// The floating tab bar and the colors of its labels.
  final Color tabBar;
  final Color tabBarBorder;
  final Color onTabBar;
  final Color onTabBarMuted;

  /// Gradient of the central Log button and the Saved check, and the color
  /// of the glyph drawn over it.
  final List<Color> logGradient;
  final Color onLogGradient;

  final MoodTint positive;
  final MoodTint peaceful;
  final MoodTint neutral;
  final MoodTint hard;
  final MoodTint angry;

  /// Error messages and destructive text.
  final Color danger;

  bool get isDark => brightness == Brightness.dark;

  MoodTint tint(MoodTone tone) {
    switch (tone) {
      case MoodTone.positive:
        return positive;
      case MoodTone.peaceful:
        return peaceful;
      case MoodTone.neutral:
        return neutral;
      case MoodTone.hard:
        return hard;
      case MoodTone.angry:
        return angry;
    }
  }

  LinearGradient get logLinearGradient => LinearGradient(
        colors: logGradient,
        stops: const [0, 0.55, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const light = BrandPalette(
    brightness: Brightness.light,
    ink: Color(0xFF1D1D22),
    onInk: Color(0xFFFFFFFF),
    text: Color(0xFF1D1D22),
    textSecondary: Color(0xFF575969),
    background: Color(0xFFEEF0F1),
    mesh: [
      Color(0xFFCFF3E4),
      Color(0xFFDCD3FF),
      Color(0xFFF9D6EA),
      Color(0xFFD3E9FF),
    ],
    glassFill: Color(0xA6FFFFFF),
    glassBorder: Color(0xCCFFFFFF),
    glassOpaque: Color(0xFFFAFAFB),
    shadow: Color(0x0F1D1D22),
    tabBar: Color(0xFF1D1D22),
    tabBarBorder: Color(0x00000000),
    onTabBar: Color(0xFFFFFFFF),
    onTabBarMuted: Color(0xA8FFFFFF),
    logGradient: [Color(0xFFB9A6FF), Color(0xFFF7B2D9), Color(0xFFFFD3B6)],
    onLogGradient: Color(0xFF1D1D22),
    positive: MoodTint(fill: Color(0xFFFFF1CC), ring: Color(0xFF9A6500)),
    peaceful: MoodTint(fill: Color(0xFFD7F5E8), ring: Color(0xFF1C7F5B)),
    neutral: MoodTint(fill: Color(0xFFECE9F5), ring: Color(0xFF5F5880)),
    hard: MoodTint(fill: Color(0xFFE5E1FF), ring: Color(0xFF5646D1)),
    angry: MoodTint(fill: Color(0xFFFDE1DF), ring: Color(0xFFC23A35)),
    danger: Color(0xFFB3261E),
  );

  static const dark = BrandPalette(
    brightness: Brightness.dark,
    ink: Color(0xFFF4F3F7),
    onInk: Color(0xFF1D1D22),
    text: Color(0xFFF4F3F7),
    textSecondary: Color(0xFFB4B6C3),
    background: Color(0xFF111114),
    mesh: [
      Color(0xFF1E3B33),
      Color(0xFF2B2547),
      Color(0xFF3D2333),
      Color(0xFF1E2E42),
    ],
    glassFill: Color(0x12FFFFFF),
    glassBorder: Color(0x1FFFFFFF),
    glassOpaque: Color(0xFF1C1C21),
    shadow: Color(0x8C000000),
    tabBar: Color(0xFF26262C),
    tabBarBorder: Color(0x1FFFFFFF),
    onTabBar: Color(0xFFFFFFFF),
    onTabBarMuted: Color(0xB3FFFFFF),
    logGradient: [Color(0xFFB9A6FF), Color(0xFFF7B2D9), Color(0xFFFFD3B6)],
    onLogGradient: Color(0xFF1D1D22),
    positive: MoodTint(fill: Color(0xFF3A3220), ring: Color(0xFFF5B83D)),
    peaceful: MoodTint(fill: Color(0xFF183A2E), ring: Color(0xFF3DBF8F)),
    neutral: MoodTint(fill: Color(0xFF2A2838), ring: Color(0xFFB3ADD1)),
    hard: MoodTint(fill: Color(0xFF26224A), ring: Color(0xFFA396FF)),
    angry: MoodTint(fill: Color(0xFF3D2221), ring: Color(0xFFF0605A)),
    danger: Color(0xFFFFB4AB),
  );

  /// The palette of the nearest theme. Falls back to the light variant when
  /// the widget tree has no [BrandPalette] (e.g. a bare `MaterialApp`).
  static BrandPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<BrandPalette>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  BrandPalette copyWith({Brightness? brightness}) =>
      brightness == Brightness.dark ? dark : light;

  @override
  BrandPalette lerp(ThemeExtension<BrandPalette>? other, double t) {
    if (other is! BrandPalette) return this;
    return t < 0.5 ? this : other;
  }
}
