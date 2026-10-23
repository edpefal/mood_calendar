import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_reporter.dart';

class FirebaseAnalyticsReporter implements AnalyticsReporter {
  FirebaseAnalyticsReporter({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) {
    return _analytics.logEvent(
      name: name,
      parameters: parameters.isEmpty ? null : parameters,
    );
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return _analytics.setAnalyticsCollectionEnabled(enabled);
  }
}
