import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'crash_reporter.dart';

class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordFatal(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
  }) {
    return _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: true,
    );
  }

  @override
  Future<void> recordNonFatal(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, Object?> context = const {},
  }) {
    return _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      information: [
        for (final entry in context.entries) '${entry.key}=${entry.value}',
      ],
    );
  }
}
