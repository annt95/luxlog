import 'package:flutter/foundation.dart';
import 'logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/config/env.dart';

/// Centralized error reporting service.
/// In debug mode: logs to console.
/// In release mode: forwards to external service (Sentry / HTTP endpoint).
class ErrorReporter {
  static final ErrorReporter _instance = ErrorReporter._();
  factory ErrorReporter() => _instance;
  ErrorReporter._();

  bool _initialized = false;

  /// Initialize error reporting infrastructure.
  /// Call once in main() before runApp().
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    // Catch Flutter framework errors
    final original = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      reportFlutterError(details);
      original?.call(details);
    };

    // Catch async errors not caught by Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      reportError(error, stack, context: 'PlatformDispatcher.onError');
      return true;
    };

    AppLogger.info('ErrorReporter initialized');
  }

  /// Report a generic error with optional context description.
  void reportError(Object error, StackTrace? stackTrace, {String? context}) {
    AppLogger.error(
      context ?? 'Unhandled error',
      error,
      stackTrace,
    );

    if (kReleaseMode && Env.sentryDsn.isNotEmpty) {
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  /// Report a Flutter framework error.
  void reportFlutterError(FlutterErrorDetails details) {
    AppLogger.error(
      'Flutter error: ${details.context?.toString() ?? 'unknown context'}',
      details.exception,
      details.stack,
    );
  }
}
