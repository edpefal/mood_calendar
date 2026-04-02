abstract class AppLogger {
  void debug(
    String message, {
    String tag,
    Object? error,
    StackTrace? stackTrace,
  });

  void error(
    String message, {
    String tag,
    Object? error,
    StackTrace? stackTrace,
  });
}
