import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/telemetry/analytics_bootstrap.dart';
import 'package:mood_calendar/core/telemetry/analytics_reporter.dart';

import '../../support/fake_analytics_reporter.dart';
import '../../support/fake_crash_reporter.dart';

void main() {
  late FakeAnalyticsReporter reporter;
  late RecordingLogger logger;
  late int created;

  Future<AnalyticsReporter?> initialize({
    bool enabled = true,
    bool firebaseReady = true,
    bool isRelease = true,
    bool isWeb = false,
    TargetPlatform platform = TargetPlatform.iOS,
    AnalyticsReporter Function()? createReporter,
  }) {
    return initializeAnalytics(
      logger: logger,
      usageAnalyticsEnabled: enabled,
      firebaseReady: firebaseReady,
      isRelease: isRelease,
      isWeb: isWeb,
      platform: platform,
      createReporter: createReporter ??
          () {
            created++;
            return reporter;
          },
    );
  }

  setUp(() {
    reporter = FakeAnalyticsReporter();
    logger = RecordingLogger();
    created = 0;
  });

  test('is active in release on iOS and Android', () async {
    expect(await initialize(platform: TargetPlatform.iOS), reporter);
    expect(await initialize(platform: TargetPlatform.android), reporter);
    expect(created, 2);
  });

  test('sends nothing outside release, on web or on desktop', () async {
    expect(await initialize(isRelease: false), isNull);
    expect(await initialize(isWeb: true), isNull);
    expect(await initialize(platform: TargetPlatform.macOS), isNull);
    expect(created, 0);
  });

  test('is off when Firebase did not initialize', () async {
    expect(await initialize(firebaseReady: false), isNull);
    expect(created, 0);
  });

  test('applies the stored preference before returning the reporter', () async {
    await initialize(enabled: false);
    await initialize(enabled: true);

    expect(reporter.collectionChanges, [false, true]);
  });

  test('a failure returns null and logs instead of throwing', () async {
    reporter.throwSync = StateError('no plist');

    expect(await initialize(), isNull);
    expect(logger.errors, hasLength(1));
  });

  test('a reporter that cannot be created leaves the app without analytics',
      () async {
    final result = await initialize(
      createReporter: () => throw StateError('plugin missing'),
    );

    expect(result, isNull);
    expect(logger.errors, hasLength(1));
  });
}
