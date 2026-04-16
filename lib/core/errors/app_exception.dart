sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'Lỗi kết nối mạng']) : super(message);
}

class AuthException extends AppException {
  const AuthException([String message = 'Lỗi xác thực']) : super(message);
}

class StorageException extends AppException {
  const StorageException([String message = 'Lỗi tải lên/tải xuống dữ liệu']) : super(message);
}

class ValidationException extends AppException {
  const ValidationException([String message = 'Lỗi xác thực dữ liệu đầu vào']) : super(message);
}

class UnknownException extends AppException {
  const UnknownException([String message = 'Đã xảy ra lỗi không xác định']) : super(message);
}
