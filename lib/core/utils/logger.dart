import 'dart:developer' as developer;

class AppLogger {
  // Prevent instantiation
  AppLogger._();

  /// Logs a Debug message
  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace);
  }

  /// Logs an Info message
  static void i(String message, [Object? error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace);
  }

  /// Logs a Warning message
  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace);
  }

  /// Logs an Error message
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace);
  }

  static void _log(String level, String message, Object? error, StackTrace? stackTrace) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final logMessage = '[$timestamp] [$level] $message';
    
    developer.log(
      logMessage,
      name: 'KisanMarket',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
