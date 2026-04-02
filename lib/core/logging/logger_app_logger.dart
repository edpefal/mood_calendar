import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'app_logger.dart';

class LoggerAppLogger implements AppLogger {
  LoggerAppLogger({Logger? logger}) : _logger = logger ?? _buildLogger();

  static const String _defaultTag = 'MoodCalendar';

  final Logger _logger;

  @override
  void debug(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.d('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  @override
  void error(
    String message, {
    String tag = _defaultTag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e('[$tag] $message', error: error, stackTrace: stackTrace);
  }

  static Logger _buildLogger() {
    return Logger(
      filter: _ReleaseAwareFilter(),
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 100,
        colors: false,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }
}

class _ReleaseAwareFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    if (kDebugMode) {
      return true;
    }

    return event.level == Level.error || event.level == Level.fatal;
  }
}
