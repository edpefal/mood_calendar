/// Destino de las analíticas de uso. Aísla el SDK del resto de la app para
/// poder probar sin plugins.
abstract class AnalyticsReporter {
  /// Envía un evento ya filtrado (solo nombres y parámetros permitidos).
  Future<void> logEvent(String name, Map<String, Object> parameters);

  /// Enciende o apaga la recolección. Apagada, el SDK no envía nada, ni
  /// siquiera sus eventos automáticos.
  Future<void> setCollectionEnabled(bool enabled);
}

/// Reporter para cuando Analytics no está activo (debug, tests, plataformas
/// sin Firebase o fallo al inicializar): no hace nada.
class NoopAnalyticsReporter implements AnalyticsReporter {
  const NoopAnalyticsReporter();

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}
}
