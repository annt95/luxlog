import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/services/logger.dart';
import 'package:luxlog/core/services/error_reporter.dart';
import 'package:luxlog/core/services/analytics_service.dart';

void main() {
  group('AppLogger', () {
    test('does not throw on any log level', () {
      expect(() => AppLogger.debug('debug msg'), returnsNormally);
      expect(() => AppLogger.info('info msg'), returnsNormally);
      expect(() => AppLogger.warn('warn msg'), returnsNormally);
      expect(() => AppLogger.error('error msg'), returnsNormally);
    });

    test('handles error with stackTrace', () {
      expect(
        () => AppLogger.error('test', Exception('boom'), StackTrace.current),
        returnsNormally,
      );
    });

    test('handles null context', () {
      expect(() => AppLogger.info('msg', null), returnsNormally);
    });
  });

  group('ErrorReporter', () {
    test('singleton returns same instance', () {
      final a = ErrorReporter();
      final b = ErrorReporter();
      expect(identical(a, b), isTrue);
    });

    test('initialize can be called multiple times safely', () {
      expect(() {
        ErrorReporter().initialize();
        ErrorReporter().initialize();
      }, returnsNormally);
    });

    test('reportError does not throw', () {
      expect(
        () => ErrorReporter().reportError(
          Exception('test'),
          StackTrace.current,
          context: 'unit test',
        ),
        returnsNormally,
      );
    });
  });

  group('AnalyticsService', () {
    test('singleton returns same instance', () {
      final a = AnalyticsService();
      final b = AnalyticsService();
      expect(identical(a, b), isTrue);
    });

    test('all track methods execute without error', () {
      final svc = AnalyticsService();
      expect(() => svc.trackSignupCompleted(method: 'email'), returnsNormally);
      expect(() => svc.trackPhotoUploaded(photoId: 'abc', isFilm: true), returnsNormally);
      expect(() => svc.trackPhotoLiked(photoId: 'abc'), returnsNormally);
      expect(() => svc.trackProfileViewed(username: 'john'), returnsNormally);
      expect(() => svc.trackSearchPerformed(query: 'sunset'), returnsNormally);
      expect(() => svc.trackPhotoViewed(photoId: 'xyz'), returnsNormally);
    });
  });
}
