import 'package:flutter/foundation.dart';

class AppTelemetryConfig {
  const AppTelemetryConfig({
    required this.eventsEnabled,
    required this.errorsEnabled,
  });

  final bool eventsEnabled;
  final bool errorsEnabled;

  factory AppTelemetryConfig.fromEnvironment() {
    return const AppTelemetryConfig(
      eventsEnabled: bool.fromEnvironment(
        'ENABLE_APP_TELEMETRY',
        defaultValue: !kReleaseMode,
      ),
      errorsEnabled: bool.fromEnvironment(
        'ENABLE_ERROR_TELEMETRY',
        defaultValue: true,
      ),
    );
  }
}
