import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../logging/app_logger.dart';
import 'app_telemetry_config.dart';
import 'crash_reporter.dart';
import 'firebase_crash_reporter.dart';

const _tag = 'CrashReporting';

/// Activa el reporte de crashes solo en release, en iOS y Android, y registra
/// los hooks globales de error. Devuelve `null` si no aplica o si la
/// inicialización falla: la app arranca igual, solo con log local.
///
/// Nunca espera nada que dependa del usuario, así que es seguro llamarla antes
/// de `runApp()`.
Future<CrashReporter?> initializeCrashReporting({
  required AppLogger logger,
  required AppTelemetryConfig config,
  bool isRelease = kReleaseMode,
  bool isWeb = kIsWeb,
  TargetPlatform? platform,
  Future<CrashReporter> Function()? createReporter,
}) async {
  final resolvedPlatform = platform ?? defaultTargetPlatform;
  final supportedPlatform = resolvedPlatform == TargetPlatform.iOS ||
      resolvedPlatform == TargetPlatform.android;
  if (!isRelease || isWeb || !supportedPlatform || !config.errorsEnabled) {
    return null;
  }

  try {
    final reporter = await (createReporter ?? _createFirebaseReporter)();
    installGlobalErrorHandlers(reporter, logger: logger);
    return reporter;
  } catch (error, stackTrace) {
    logger.error(
      'Crash reporting could not be initialized; continuing without it.',
      tag: _tag,
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}

Future<CrashReporter> _createFirebaseReporter() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  return FirebaseCrashReporter();
}

/// Reenvía los errores de Flutter y los asíncronos sin manejar al [reporter].
/// Conserva el comportamiento previo de `FlutterError.onError` (imprimir).
@visibleForTesting
void installGlobalErrorHandlers(
  CrashReporter reporter, {
  required AppLogger logger,
}) {
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    previousOnError?.call(details);
    _safely(
      logger,
      () => reporter.recordFatal(
        details.exception,
        details.stack,
        reason: details.exceptionAsString(),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    _safely(logger, () => reporter.recordFatal(error, stackTrace));
    return true;
  };
}

void _safely(AppLogger logger, Future<void> Function() record) {
  void logFailure(Object failure, StackTrace stackTrace) {
    logger.error(
      'Crash reporter failed to record a fatal error.',
      tag: _tag,
      error: failure,
      stackTrace: stackTrace,
    );
  }

  try {
    unawaited(record().catchError(logFailure));
  } catch (failure, stackTrace) {
    logFailure(failure, stackTrace);
  }
}
