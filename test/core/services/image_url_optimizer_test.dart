import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/services/image_url_optimizer.dart';

void main() {
  group('optimizeImageUrl', () {
    test('returns empty string for empty input', () {
      expect(optimizeImageUrl(''), isEmpty);
    });

    test('returns trimmed URL for whitespace-only input', () {
      expect(optimizeImageUrl('   '), isEmpty);
    });

    test('returns original URL when transforms are disabled', () {
      const url =
          'https://abc.supabase.co/storage/v1/object/public/photos/uploads/user1/img.jpg';
      final result = optimizeImageUrl(url, width: 400);
      // Since _imageTransformsEnabled = false, should return original
      expect(result, url);
    });

    test('returns original URL unchanged for non-Supabase URLs', () {
      const url = 'https://example.com/images/photo.jpg';
      final result = optimizeImageUrl(url, width: 800);
      expect(result, url);
    });

    test('handles URL with existing query parameters', () {
      const url =
          'https://abc.supabase.co/storage/v1/object/public/photos/img.jpg?token=abc';
      final result = optimizeImageUrl(url, width: 400);
      // Disabled, so returns original
      expect(result, url);
    });

    test('handles malformed URL gracefully', () {
      const url = 'not a valid url ://broken';
      final result = optimizeImageUrl(url);
      expect(result, url);
    });

    test('preserves URL when width is null and transforms disabled', () {
      const url =
          'https://abc.supabase.co/storage/v1/object/public/photos/test.png';
      final result = optimizeImageUrl(url);
      expect(result, url);
    });
  });
}
