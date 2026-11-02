import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/theme/brand_colors.dart';

void main() {
  group('brand colors', () {
    test('white text is readable on both ends of the gradient', () {
      const white = Color(0xFFFFFFFF);
      expect(_contrast(white, brandGradientStart), greaterThanOrEqualTo(4.5));
      expect(_contrast(white, brandGradientEnd), greaterThanOrEqualTo(4.5));
    });

    test('the ink is the start of the gradient', () {
      expect(brandInk, brandGradientStart);
    });
  });
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
