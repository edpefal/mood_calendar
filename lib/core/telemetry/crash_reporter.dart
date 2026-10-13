/// Destino de los reportes de fallos. Aísla el SDK de crashes del resto de la
/// app para poder probar sin plugins.
abstract class CrashReporter {
  /// Error no manejado que la app no pudo recuperar.
  Future<void> recordFatal(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
  });

  /// Error manejado por la app que vale la pena ver en el dashboard.
  Future<void> recordNonFatal(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, Object?> context = const {},
  });
}
