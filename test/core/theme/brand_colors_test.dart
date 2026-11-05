import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/theme/brand_colors.dart';

void main() {
  final palettes = {
    'light': BrandPalette.light,
    'dark': BrandPalette.dark,
  };

  for (final entry in palettes.entries) {
    final name = entry.key;
    final p = entry.value;

    group('$name palette contrast', () {
      test('text pairs are readable (4.5:1)', () {
        final pairs = <String, (Color, Color)>{
          'text on background': (p.text, p.background),
          'secondary text on background': (p.textSecondary, p.background),
          'text on opaque glass': (p.text, p.glassOpaque),
          'secondary text on opaque glass': (p.textSecondary, p.glassOpaque),
          'onInk on ink': (p.onInk, p.ink),
          'tab bar label on tab bar': (p.onTabBar, p.tabBar),
          'muted tab bar label on tab bar': (p.onTabBarMuted, p.tabBar),
          'glyph on log gradient start': (p.onLogGradient, p.logGradient[0]),
          'glyph on log gradient middle': (p.onLogGradient, p.logGradient[1]),
          'glyph on log gradient end': (p.onLogGradient, p.logGradient[2]),
          'danger on background': (p.danger, p.background),
        };
        for (final pair in pairs.entries) {
          final (fg, bg) = pair.value;
          expect(
            _contrast(_over(fg, bg), bg),
            greaterThanOrEqualTo(4.5),
            reason: '$name: ${pair.key}',
          );
        }
      });

      test('text stays readable over every mesh blob', () {
        for (final blob in p.mesh) {
          expect(_contrast(p.text, blob), greaterThanOrEqualTo(4.5));
          expect(_contrast(p.textSecondary, blob), greaterThanOrEqualTo(4.5));
        }
      });

      test('text stays readable on the translucent glass fill', () {
        for (final blob in [p.background, ...p.mesh]) {
          final glass = _over(p.glassFill, blob);
          expect(_contrast(p.text, glass), greaterThanOrEqualTo(4.5));
          expect(_contrast(p.textSecondary, glass), greaterThanOrEqualTo(4.5));
        }
      });

      for (final tone in MoodTone.values) {
        test('${tone.name} tint carries text and shows its ring', () {
          final tint = p.tint(tone);
          expect(_contrast(p.text, tint.fill), greaterThanOrEqualTo(4.5));
          expect(
            _contrast(p.textSecondary, tint.fill),
            greaterThanOrEqualTo(4.5),
            reason: 'locked cells use the secondary text on the tint',
          );
          expect(
            _contrast(tint.ring, tint.fill),
            greaterThanOrEqualTo(3.0),
            reason: 'selection ring is a non-text indicator (3:1)',
          );
        });
      }
    });
  }

  test('the dark tab bar is distinguishable from the dark background', () {
    expect(
      _contrast(BrandPalette.dark.tabBar, BrandPalette.dark.background),
      greaterThanOrEqualTo(1.1),
    );
    expect(BrandPalette.dark.tabBarBorder.a, greaterThan(0));
  });
}

/// Composites [top] over an opaque [bottom].
Color _over(Color top, Color bottom) {
  final a = top.a;
  return Color.from(
    alpha: 1,
    red: top.r * a + bottom.r * (1 - a),
    green: top.g * a + bottom.g * (1 - a),
    blue: top.b * a + bottom.b * (1 - a),
  );
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
