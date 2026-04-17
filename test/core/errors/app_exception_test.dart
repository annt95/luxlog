import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/errors/app_exception.dart';

void main() {
  group('AppException Tests', () {
    test('NetworkException should store correct message', () {
      const exception = NetworkException('Lỗi kết nối mạng');
      expect(exception.message, 'Lỗi kết nối mạng');
      expect(exception.toString(), 'Lỗi kết nối mạng');
    });

    test('NetworkException should accept custom message', () {
      const exception = NetworkException('Custom error');
      expect(exception.message, 'Custom error');
    });

    test('AuthException should store correct message', () {
      const exception = AuthException('Lỗi xác thực');
      expect(exception.message, 'Lỗi xác thực');
    });

    test('StorageException should store correct message', () {
      const exception = StorageException('Lỗi tải lên/tải xuống dữ liệu');
      expect(exception.message, 'Lỗi tải lên/tải xuống dữ liệu');
    });

    test('ValidationException should store correct message', () {
      const exception = ValidationException('Lỗi xác thực dữ liệu đầu vào');
      expect(exception.message, 'Lỗi xác thực dữ liệu đầu vào');
    });

    test('UnknownException should store correct message', () {
      const exception = UnknownException('Đã xảy ra lỗi không xác định');
      expect(exception.message, 'Đã xảy ra lỗi không xác định');
    });
  });
}
