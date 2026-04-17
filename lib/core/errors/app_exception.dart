sealed class AppException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const AppException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class AuthException extends AppException {
  const AuthException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class StorageException extends AppException {
  const StorageException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class ValidationException extends AppException {
  const ValidationException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class UnknownException extends AppException {
  const UnknownException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}
