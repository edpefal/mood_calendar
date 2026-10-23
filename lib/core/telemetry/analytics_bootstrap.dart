import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';
import 'analytics_reporter.dart';
import 'firebase_analytics_reporter.dart';

const _tag = 'Analytics';

/// Activa las analíticas de uso solo en release, en iOS y Android, cuando
/// Firebase ya se inicializó y el usuario no las desactivó. Aplica la
/// preferencia al SDK antes de devolver el reporter, así nada se envía antes
/// de leerla. Devuelve `null` si no aplica o si falla: la app sigue con log
/// local.
///
/// Nunca espera nada que dependa del usuario, así que es seguro llamarla
/// antes de `runApp()`.
Future<AnalyticsReporter?> initializeAnalytics({
  required AppLogger logger,
  required bool usageAnalyticsEnabled,
  bool firebaseReady = true,
  bool isRelease = kReleaseMode,
  bool isWeb = kIsWeb,
  TargetPlatform? platform,
  AnalyticsReporter Function()? createReporter,
}) async {
  final resolvedPlatform = platform ?? defaultTargetPlatform;
  final supportedPlatform = resolvedPlatform == TargetPlatform.iOS ||
      resolvedPlatform == TargetPlatform.android;
  if (!isRelease || isWeb || !supportedPlatform || !firebaseReady) {
    return null;
  }

  try {
    final reporter = (createReporter ?? FirebaseAnalyticsReporter.new)();
    await reporter.setCollectionEnabled(usageAnalyticsEnabled);
    return reporter;
  } catch (error, stackTrace) {
    logger.error(
      'Analytics could not be initialized; continuing without it.',
      tag: _tag,
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}

/// Firebase se inicializa en `initializeCrashReporting`; Analytics solo se
/// activa si ya hay una app de Firebase.
bool isFirebaseInitialized() => Firebase.apps.isNotEmpty;
