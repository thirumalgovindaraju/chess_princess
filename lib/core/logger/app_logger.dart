// lib/core/logger/app_logger.dart

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class AppLogger {
  static const String _tag = '🎯 ChessPrincess';
  static LogLevel _minimumLevel = LogLevel.debug;

  /// Set the minimum log level to display
  static void setMinimumLevel(LogLevel level) {
    _minimumLevel = level;
  }

  /// Log a debug message
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  /// Log an info message
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  /// Log a warning message
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  /// Log an error message
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  /// Log a fatal message
  void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, error, stackTrace);
  }

  void _log(
      LogLevel level,
      String message, [
        Object? error,
        StackTrace? stackTrace,
      ]) {
    if (level.index < _minimumLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelString = level.toString().split('.').last.toUpperCase();
    final logMessage = '[$timestamp] $_tag [$levelString] $message';

    // Print to console
    print(logMessage);

    if (error != null) {
      print('Error: $error');
    }

    if (stackTrace != null) {
      print('StackTrace:\n$stackTrace');
    }

    // You can add additional logging backends here (Firebase Crashlytics, Sentry, etc.)
  }
}