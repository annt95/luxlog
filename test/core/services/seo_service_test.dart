import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/services/seo_service.dart';

void main() {
  group('SeoService', () {
    // SeoService only runs on web — we test the metadata generation logic
    // by verifying it doesn't crash on non-web platforms.

    test('applyForPath does not throw on non-web for root', () {
      expect(
        () => SeoService.applyForPath('/'),
        returnsNormally,
      );
    });

    test('applyForPath does not throw for /explore', () {
      expect(
        () => SeoService.applyForPath('/explore'),
        returnsNormally,
      );
    });

    test('applyForPath does not throw for photo detail', () {
      expect(
        () => SeoService.applyForPath(
          '/photo/:id',
          pathParameters: {'id': 'abc-123'},
        ),
        returnsNormally,
      );
    });

    test('applyForPath does not throw for user profile', () {
      expect(
        () => SeoService.applyForPath(
          '/u/:username',
          pathParameters: {'username': 'john'},
        ),
        returnsNormally,
      );
    });

    test('applyForPath does not throw for tag feed', () {
      expect(
        () => SeoService.applyForPath(
          '/tag/:tagName',
          pathParameters: {'tagName': 'portra400'},
        ),
        returnsNormally,
      );
    });

    test('applyForPath does not throw for private routes', () {
      for (final route in ['/login', '/signup', '/upload', '/notifications', '/profile/edit']) {
        expect(
          () => SeoService.applyForPath(route),
          returnsNormally,
        );
      }
    });

    test('applyForPath handles empty path', () {
      expect(
        () => SeoService.applyForPath(''),
        returnsNormally,
      );
    });
  });
}
