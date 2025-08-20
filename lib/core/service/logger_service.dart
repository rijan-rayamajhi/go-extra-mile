import 'dart:developer' as developer;

/// LoggerService centralizes app logging.
/// You can extend this to integrate with remote logging platforms if needed.
class LoggerService {
  /// Whether logging is enabled (e.g., disable in production).
  bool _isLoggingEnabled;

  LoggerService({bool isLoggingEnabled = true}) : _isLoggingEnabled = isLoggingEnabled;

  /// Log an informational message.
  void info(String message, {String? tag}) {
    if (!_isLoggingEnabled) return;
    developer.log(message, name: tag ?? 'INFO');
  }

  /// Log a warning message.
  void warning(String message, {String? tag}) {
    if (!_isLoggingEnabled) return;
    developer.log('WARNING: $message', name: tag ?? 'WARNING');
  }

  /// Log an error message with optional error and stack trace.
  void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (!_isLoggingEnabled) return;
    developer.log('ERROR: $message', error: error, stackTrace: stackTrace, name: tag ?? 'ERROR');
  }

  /// Enable or disable logging at runtime.
  void setLoggingEnabled(bool enabled) {
    _isLoggingEnabled = enabled;
  }
}
