sealed class AppException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  const AppException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([
    String message = 'Lỗi kết nối mạng',
  ], {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class AuthException extends AppException {
  const AuthException([
    String message = 'Lỗi xác thực',
  ], {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class StorageException extends AppException {
  const StorageException([
    String message = 'Lỗi tải lên/tải xuống dữ liệu',
  ], {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class ValidationException extends AppException {
  const ValidationException([
    String message = 'Lỗi xác thực dữ liệu đầu vào',
  ], {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class UnknownException extends AppException {
  const UnknownException([
    String message = 'Đã xảy ra lỗi không xác định',
  ], {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}
