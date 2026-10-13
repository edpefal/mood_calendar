import 'package:mood_calendar/core/logging/app_logger.dart';
import 'package:mood_calendar/core/telemetry/crash_reporter.dart';

class RecordedCrash {
  RecordedCrash({
    required this.error,
    required this.stackTrace,
    required this.reason,
    this.context = const {},
  });

  final Object error;
  final StackTrace? stackTrace;
  final String? reason;
  final Map<String, Object?> context;
}

class FakeCrashReporter implements CrashReporter {
  /// Si no es nulo, ambos métodos lanzan esto de forma síncrona.
  Object? throwSync;

  /// Si no es nulo, ambos métodos devuelven un Future que falla con esto.
  Object? failAsync;

  final List<RecordedCrash> fatals = [];
  final List<RecordedCrash> nonFatals = [];

  @override
  Future<void> recordFatal(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
  }) async {
    if (throwSync != null) throw throwSync!;
    fatals.add(
      RecordedCrash(error: error, stackTrace: stackTrace, reason: reason),
    );
    if (failAsync != null) throw failAsync!;
  }

  @override
  Future<void> recordNonFatal(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, Object?> context = const {},
  }) {
    if (throwSync != null) throw throwSync!;
    nonFatals.add(
      RecordedCrash(
        error: error,
        stackTrace: stackTrace,
        reason: reason,
        context: context,
      ),
    );
    if (failAsync != null) return Future.error(failAsync!);
    return Future.value();
  }
}

class RecordingLogger implements AppLogger {
  final List<String> errors = [];

  @override
  void debug(
    String message, {
    String tag = '',
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void error(
    String message, {
    String tag = '',
    Object? error,
    StackTrace? stackTrace,
  }) {
    errors.add(message);
  }
}
