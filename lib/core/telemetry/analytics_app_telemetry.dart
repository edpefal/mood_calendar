import 'dart:async';

import '../logging/app_logger.dart';
import 'analytics_reporter.dart';
import 'app_telemetry.dart';
import 'app_telemetry_events.dart';
import 'telemetry_privacy.dart';

/// Envuelve otra [AppTelemetry]: todo sigue yendo al destino original y,
/// además, los eventos de la lista cerrada se reenvían a [AnalyticsReporter]
/// solo con los parámetros permitidos. `recordError` nunca sale por aquí.
class AnalyticsAppTelemetry implements AppTelemetry {
  AnalyticsAppTelemetry({
    required AppTelemetry delegate,
    required AnalyticsReporter reporter,
    required AppLogger logger,
  })  : _delegate = delegate,
        _reporter = reporter,
        _logger = logger;

  static const _tag = 'AnalyticsAppTelemetry';

  final AppTelemetry _delegate;
  final AnalyticsReporter _reporter;
  final AppLogger _logger;

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    _delegate.trackEvent(name, properties: properties);
    if (!AppTelemetryEvents.analyticsAllowlist.contains(name)) {
      return;
    }

    final parameters = <String, Object>{
      for (final entry in properties.entries)
        if (!blockedContextKeys.contains(entry.key) &&
            AppTelemetryEvents.analyticsParameterAllowlist
                .contains(entry.key) &&
            entry.value != null)
          entry.key: entry.value!,
    };
    try {
      unawaited(
        _reporter.logEvent(name, parameters).catchError(_logReporterFailure),
      );
    } catch (failure, stackTrace) {
      _logReporterFailure(failure, stackTrace);
    }
  }

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    _delegate.recordError(
      name,
      reason: reason,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _logReporterFailure(Object failure, StackTrace stackTrace) {
    _logger.error(
      'Analytics reporter failed to log an event.',
      tag: _tag,
      error: failure,
      stackTrace: stackTrace,
    );
  }
}
