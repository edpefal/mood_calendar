import 'package:mood_calendar/core/telemetry/analytics_reporter.dart';

class LoggedAnalyticsEvent {
  LoggedAnalyticsEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;
}

class FakeAnalyticsReporter implements AnalyticsReporter {
  /// Si no es nulo, ambos métodos lanzan esto de forma síncrona.
  Object? throwSync;

  /// Si no es nulo, ambos métodos devuelven un Future que falla con esto.
  Object? failAsync;

  final List<LoggedAnalyticsEvent> events = [];
  final List<bool> collectionChanges = [];

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) {
    if (throwSync != null) throw throwSync!;
    events.add(LoggedAnalyticsEvent(name, parameters));
    if (failAsync != null) return Future.error(failAsync!);
    return Future.value();
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    if (throwSync != null) throw throwSync!;
    collectionChanges.add(enabled);
    if (failAsync != null) return Future.error(failAsync!);
    return Future.value();
  }
}
