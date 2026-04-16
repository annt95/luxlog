import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/errors/app_exception.dart';

void main() {
  group('AppException Tests', () {
    test('NetworkException should have correct default message', () {
      const exception = NetworkException();
      expect(exception.message, 'Lỗi kết nối mạng');
      expect(exception.toString(), 'Lỗi kết nối mạng');
    });

    test('NetworkException should accept custom message', () {
      const exception = NetworkException('Custom error');
      expect(exception.message, 'Custom error');
    });

    test('AuthException should have correct default message', () {
      const exception = AuthException();
      expect(exception.message, 'Lỗi xác thực');
    });

    test('StorageException should have correct default message', () {
      const exception = StorageException();
      expect(exception.message, 'Lỗi tải lên/tải xuống dữ liệu');
    });

    test('ValidationException should have correct default message', () {
      const exception = ValidationException();
      expect(exception.message, 'Lỗi xác thực dữ liệu đầu vào');
    });

    test('UnknownException should have correct default message', () {
      const exception = UnknownException();
      expect(exception.message, 'Đã xảy ra lỗi không xác định');
    });
  });
}
