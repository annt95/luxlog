import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warn, error }

class AppLogger {
  static void debug(String message, [Object? context]) {
    _log(LogLevel.debug, message, context);
  }

  static void info(String message, [Object? context]) {
    _log(LogLevel.info, message, context);
  }

  static void warn(String message, [Object? context]) {
    _log(LogLevel.warn, message, context);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error);
    if (stackTrace != null && kDebugMode) {
      debugPrintStack(stackTrace: stackTrace, label: message, maxFrames: 10);
    }
  }

  static void _log(LogLevel level, String message, [Object? context]) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String().substring(11, 23);
    final prefix = level.name.toUpperCase().padRight(5);
    final ctx = context != null ? ' | $context' : '';
    debugPrint('[$timestamp] $prefix $message$ctx');
  }
}
