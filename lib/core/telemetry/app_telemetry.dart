abstract class AppTelemetry {
  void trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  });

  void recordError(
    String name, {
    String? reason,
    Map<String, Object?> context = const {},
    Object? error,
    StackTrace? stackTrace,
  });
}
