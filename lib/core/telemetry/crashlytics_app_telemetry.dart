import 'dart:async';

import '../logging/app_logger.dart';
import 'app_telemetry.dart';
import 'app_telemetry_config.dart';
import 'crash_reporter.dart';

/// Envuelve otra [AppTelemetry]: todo sigue yendo al destino original (el log
/// local) y además `recordError` se reenvía a [CrashReporter] como no fatal.
class CrashlyticsAppTelemetry implements AppTelemetry {
  CrashlyticsAppTelemetry({
    required AppTelemetry delegate,
    required CrashReporter reporter,
    required AppLogger logger,
    required AppTelemetryConfig config,
  })  : _delegate = delegate,
        _reporter = reporter,
        _logger = logger,
        _config = config;

  static const _tag = 'CrashlyticsAppTelemetry';

  /// Claves de contexto que nunca salen del dispositivo: describen una entrada
  /// del usuario (fecha, mood, nota). Siguen escribiéndose en el log local.
  static const blockedContextKeys = {'date', 'mood', 'intensity', 'note'};

  final AppTelemetry _delegate;
  final CrashReporter _reporter;
  final AppLogger _logger;
  final AppTelemetryConfig _config;

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    _delegate.trackEvent(name, properties: properties);
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
    if (!_config.errorsEnabled) {
      return;
    }

    final safeContext = {
      for (final entry in context.entries)
        if (!blockedContextKeys.contains(entry.key)) entry.key: entry.value,
    };
    try {
      unawaited(
        _reporter
            .recordNonFatal(
              error ?? name,
              stackTrace ?? StackTrace.current,
              reason: reason == null ? name : '$name: $reason',
              context: safeContext,
            )
            .catchError(_logReporterFailure),
      );
    } catch (failure, failureStack) {
      _logReporterFailure(failure, failureStack);
    }
  }

  void _logReporterFailure(Object failure, StackTrace stackTrace) {
    _logger.error(
      'Crash reporter failed to record a non-fatal error.',
      tag: _tag,
      error: failure,
      stackTrace: stackTrace,
    );
  }
}
