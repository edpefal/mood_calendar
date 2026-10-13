import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry_config.dart';
import 'package:mood_calendar/core/telemetry/crashlytics_app_telemetry.dart';

import '../../support/fake_crash_reporter.dart';

class _RecordingTelemetry implements AppTelemetry {
  final List<String> events = [];
  final List<String> errors = [];
  final List<Map<String, Object?>> errorContexts = [];

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    events.add(name);
  }

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    errors.add(name);
    errorContexts.add(context);
  }
}

void main() {
  late FakeCrashReporter reporter;
  late RecordingLogger logger;
  late _RecordingTelemetry delegate;

  CrashlyticsAppTelemetry build({bool errorsEnabled = true}) {
    return CrashlyticsAppTelemetry(
      delegate: delegate,
      reporter: reporter,
      logger: logger,
      config: AppTelemetryConfig(
        eventsEnabled: true,
        errorsEnabled: errorsEnabled,
      ),
    );
  }

  setUp(() {
    reporter = FakeCrashReporter();
    logger = RecordingLogger();
    delegate = _RecordingTelemetry();
  });

  test('recordError writes to the local log and reports a non-fatal', () {
    final error = StateError('boom');
    final stack = StackTrace.current;

    build().recordError(
      'save_mood_failed',
      reason: 'save_use_case',
      context: {'timezone': 'UTC'},
      error: error,
      stackTrace: stack,
    );

    expect(delegate.errors, ['save_mood_failed']);
    expect(reporter.nonFatals, hasLength(1));
    final recorded = reporter.nonFatals.single;
    expect(recorded.error, same(error));
    expect(recorded.stackTrace, same(stack));
    expect(recorded.reason, 'save_mood_failed: save_use_case');
    expect(recorded.context, {'timezone': 'UTC'});
    expect(reporter.fatals, isEmpty);
  });

  test('recordError without an error reports the name instead', () {
    build().recordError('notification_permission_denied');

    expect(reporter.nonFatals.single.error, 'notification_permission_denied');
    expect(reporter.nonFatals.single.stackTrace, isNotNull);
  });

  test('entry data never reaches the reporter but stays in the local log', () {
    build().recordError(
      'save_mood_failed',
      context: {
        'date': '2026-10-12',
        'mood': 'happy',
        'intensity': 1,
        'note': 'private thoughts',
        'timezone': 'UTC',
      },
      error: StateError('boom'),
    );

    expect(reporter.nonFatals.single.context, {'timezone': 'UTC'});
    expect(delegate.errorContexts.single.keys, containsAll(['date', 'mood']));
  });

  test('trackEvent only goes to the delegate', () {
    build().trackEvent('mood_saved');

    expect(delegate.events, ['mood_saved']);
    expect(reporter.nonFatals, isEmpty);
    expect(reporter.fatals, isEmpty);
  });

  test('nothing is reported when error telemetry is disabled', () {
    build(errorsEnabled: false).recordError(
      'save_mood_failed',
      error: StateError('boom'),
    );

    expect(delegate.errors, ['save_mood_failed']);
    expect(reporter.nonFatals, isEmpty);
  });

  test('a reporter that throws synchronously does not reach the caller', () {
    reporter.throwSync = StateError('sdk exploded');

    expect(
      () => build().recordError('save_mood_failed', error: StateError('x')),
      returnsNormally,
    );
    expect(logger.errors, hasLength(1));
  });

  test('a reporter whose future fails does not reach the caller', () async {
    reporter.failAsync = StateError('sdk exploded');

    expect(
      () => build().recordError('save_mood_failed', error: StateError('x')),
      returnsNormally,
    );
    await Future<void>.delayed(Duration.zero);
    expect(logger.errors, hasLength(1));
  });
}
