import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/features/purchases/data/revenue_cat_config.dart';

void main() {
  const ios = 'appl_ios';
  const android = 'goog_android';

  String keyFor(TargetPlatform platform,
          {String i = ios, String a = android}) =>
      revenueCatApiKeyFor(platform, iosKey: i, androidKey: a);

  group('revenueCatApiKeyFor', () {
    test('uses the iOS key on iOS', () {
      expect(keyFor(TargetPlatform.iOS), ios);
    });

    test('uses the Android key on Android', () {
      expect(keyFor(TargetPlatform.android), android);
    });

    test('never falls back to the other store key', () {
      expect(keyFor(TargetPlatform.android, a: ''), isEmpty);
      expect(keyFor(TargetPlatform.iOS, i: ''), isEmpty);
    });

    test('has no key on platforms without store purchases', () {
      for (final platform in [
        TargetPlatform.macOS,
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.fuchsia,
      ]) {
        expect(keyFor(platform), isEmpty, reason: '$platform');
      }
    });
  });

  group('revenueCatKeyVariableFor', () {
    test('names the define of each platform', () {
      expect(revenueCatKeyVariableFor(TargetPlatform.android),
          'REVENUECAT_ANDROID_API_KEY');
      expect(revenueCatKeyVariableFor(TargetPlatform.iOS),
          'REVENUECAT_IOS_API_KEY');
    });
  });
}
