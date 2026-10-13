import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry_config.dart';
import 'package:mood_calendar/core/telemetry/crash_reporter.dart';
import 'package:mood_calendar/core/telemetry/crash_reporting_bootstrap.dart';

import '../../support/fake_crash_reporter.dart';

void main() {
  const enabled = AppTelemetryConfig(eventsEnabled: true, errorsEnabled: true);
  const disabled =
      AppTelemetryConfig(eventsEnabled: true, errorsEnabled: false);

  late FakeCrashReporter reporter;
  late RecordingLogger logger;
  late int created;

  Future<CrashReporter?> initialize({
    AppTelemetryConfig config = enabled,
    bool isRelease = true,
    bool isWeb = false,
    TargetPlatform platform = TargetPlatform.iOS,
    Future<CrashReporter> Function()? createReporter,
  }) {
    return initializeCrashReporting(
      logger: logger,
      config: config,
      isRelease: isRelease,
      isWeb: isWeb,
      platform: platform,
      createReporter: createReporter ??
          () async {
            created++;
            return reporter;
          },
    );
  }

  late FlutterExceptionHandler? originalOnError;
  late ErrorCallback? originalDispatcherOnError;

  setUp(() {
    reporter = FakeCrashReporter();
    logger = RecordingLogger();
    created = 0;
    originalOnError = FlutterError.onError;
    originalDispatcherOnError = PlatformDispatcher.instance.onError;
    FlutterError.onError = (_) {};
  });

  tearDown(() {
    FlutterError.onError = originalOnError;
    PlatformDispatcher.instance.onError = originalDispatcherOnError;
  });

  group('gating', () {
    test('is active in release on iOS and Android', () async {
      expect(await initialize(platform: TargetPlatform.iOS), reporter);
      expect(await initialize(platform: TargetPlatform.android), reporter);
      expect(created, 2);
    });

    test('is off outside release', () async {
      expect(await initialize(isRelease: false), isNull);
      expect(created, 0);
    });

    test('is off when error telemetry is disabled', () async {
      expect(await initialize(config: disabled), isNull);
      expect(created, 0);
    });

    test('is off on web and desktop', () async {
      expect(await initialize(isWeb: true), isNull);
      expect(await initialize(platform: TargetPlatform.macOS), isNull);
      expect(await initialize(platform: TargetPlatform.windows), isNull);
      expect(created, 0);
    });

    test('does not touch the global handlers when it is off', () async {
      final before = FlutterError.onError;
      await initialize(isRelease: false);
      expect(FlutterError.onError, same(before));
    });
  });

  group('initialization failure', () {
    test('returns null and logs instead of throwing', () async {
      final result = await initialize(
        createReporter: () async => throw StateError('no plist'),
      );

      expect(result, isNull);
      expect(logger.errors, hasLength(1));
    });
  });

  group('global handlers', () {
    test('Flutter framework errors are reported as fatal', () async {
      await initialize();
      final exception = StateError('widget exploded');

      FlutterError.onError!(
        FlutterErrorDetails(exception: exception, stack: StackTrace.current),
      );

      expect(reporter.fatals.single.error, same(exception));
    });

    test('unhandled async errors are reported and marked handled', () async {
      await initialize();
      final exception = StateError('async exploded');

      final handled = PlatformDispatcher.instance.onError!(
        exception,
        StackTrace.current,
      );

      expect(handled, isTrue);
      expect(reporter.fatals.single.error, same(exception));
    });

    test('a reporter that throws does not break the handlers', () async {
      await initialize();
      reporter.throwSync = StateError('sdk exploded');

      expect(
        () => FlutterError.onError!(
          FlutterErrorDetails(exception: StateError('x')),
        ),
        returnsNormally,
      );
      expect(
        PlatformDispatcher.instance.onError!(
            StateError('y'), StackTrace.current),
        isTrue,
      );
      await Future<void>.delayed(Duration.zero);
      expect(logger.errors, hasLength(2));
    });
  });
}
