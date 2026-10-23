import 'package:flutter_test/flutter_test.dart';
import 'package:mood_calendar/core/telemetry/analytics_app_telemetry.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry.dart';
import 'package:mood_calendar/core/telemetry/app_telemetry_events.dart';
import 'package:mood_calendar/core/telemetry/crashlytics_app_telemetry.dart';
import 'package:mood_calendar/core/telemetry/telemetry_privacy.dart';

import '../../support/fake_analytics_reporter.dart';
import '../../support/fake_crash_reporter.dart';

class _RecordingTelemetry implements AppTelemetry {
  final List<String> events = [];
  final List<String> errors = [];

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
  }
}

void main() {
  late _RecordingTelemetry delegate;
  late FakeAnalyticsReporter reporter;
  late RecordingLogger logger;
  late AnalyticsAppTelemetry telemetry;

  setUp(() {
    delegate = _RecordingTelemetry();
    reporter = FakeAnalyticsReporter();
    logger = RecordingLogger();
    telemetry = AnalyticsAppTelemetry(
      delegate: delegate,
      reporter: reporter,
      logger: logger,
    );
  });

  test('mood_saved never carries date, mood, intensity or note', () {
    telemetry.trackEvent(
      AppTelemetryEvents.moodSaved,
      properties: {
        'date': '2026-10-22',
        'mood': 'happy',
        'intensity': 1,
        'note': 'secret',
        'has_note': 'true',
      },
    );

    expect(reporter.events.single.name, 'mood_saved');
    expect(reporter.events.single.parameters, {'has_note': 'true'});
  });

  test('any parameter outside the allowlist is dropped', () {
    telemetry.trackEvent(
      AppTelemetryEvents.openedFromReminder,
      properties: {'source': 'notification', 'mood_id': 'anxious', 'x': null},
    );

    expect(reporter.events.single.parameters, {'source': 'notification'});
  });

  test('every allowlisted event is forwarded and blocked keys never leave', () {
    for (final name in AppTelemetryEvents.analyticsAllowlist) {
      telemetry.trackEvent(name, properties: {
        for (final key in blockedContextKeys) key: 'value',
      });
    }

    expect(reporter.events,
        hasLength(AppTelemetryEvents.analyticsAllowlist.length));
    for (final event in reporter.events) {
      expect(event.parameters, isEmpty);
    }
  });

  test('events outside the list stay in the log only', () {
    telemetry.trackEvent(
      'mood_history_exported',
      properties: {'entry_count': 3, 'file_name': 'mood-history.json'},
    );

    expect(reporter.events, isEmpty);
    expect(delegate.events, ['mood_history_exported']);
  });

  test('always writes to the delegate', () {
    telemetry.trackEvent(AppTelemetryEvents.storeOpened);

    expect(delegate.events, ['store_opened']);
  });

  test('recordError only goes to the delegate', () {
    telemetry.recordError('save_mood_failed', context: {'mood': 'happy'});

    expect(delegate.errors, ['save_mood_failed']);
    expect(reporter.events, isEmpty);
  });

  test('a reporter that throws does not reach the caller', () async {
    reporter.throwSync = StateError('sdk exploded');
    expect(
      () => telemetry.trackEvent(AppTelemetryEvents.moodSaved),
      returnsNormally,
    );

    reporter.throwSync = null;
    reporter.failAsync = StateError('async failure');
    expect(
      () => telemetry.trackEvent(AppTelemetryEvents.moodSaved),
      returnsNormally,
    );
    await Future<void>.delayed(Duration.zero);

    expect(logger.errors, hasLength(2));
  });

  test('Crashlytics and Analytics share the same blocked keys', () {
    expect(CrashlyticsAppTelemetry.blockedContextKeys, blockedContextKeys);
    expect(blockedContextKeys, {'date', 'mood', 'intensity', 'note'});
  });

  test('analytics parameters never include a blocked key', () {
    expect(
      AppTelemetryEvents.analyticsParameterAllowlist
          .intersection(blockedContextKeys),
      isEmpty,
    );
  });
}
