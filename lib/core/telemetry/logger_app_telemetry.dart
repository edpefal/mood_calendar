import '../logging/app_logger.dart';
import 'app_telemetry.dart';
import 'app_telemetry_config.dart';

class LoggerAppTelemetry implements AppTelemetry {
  LoggerAppTelemetry({
    required AppLogger logger,
    required AppTelemetryConfig config,
  })  : _logger = logger,
        _config = config;

  static const _tag = 'AppTelemetry';

  final AppLogger _logger;
  final AppTelemetryConfig _config;

  @override
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) {
    if (!_config.eventsEnabled) {
      return;
    }
    _logger.debug(
      'event=$name properties=${_formatProperties(properties)}',
      tag: _tag,
    );
  }

  @override
  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_config.errorsEnabled) {
      return;
    }
    final reasonPart = reason == null ? '' : ' reason=$reason';
    _logger.error(
      'error=$name$reasonPart context=${_formatProperties(context)}',
      tag: _tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  String _formatProperties(Map<String, Object?> properties) {
    if (properties.isEmpty) {
      return '{}';
    }

    final sanitizedEntries = properties.entries.map((entry) {
      final value = entry.value;
      return '${entry.key}=${value ?? 'null'}';
    }).join(', ');
    return '{$sanitizedEntries}';
  }
}
