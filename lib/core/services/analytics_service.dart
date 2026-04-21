import 'logger.dart';

/// Lightweight analytics service for tracking key user funnels.
/// In v1: logs events locally. Can be extended to Vercel Analytics,
/// Supabase events table, or any third-party analytics provider.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  /// Active timers for duration tracking
  final Map<String, Stopwatch> _timers = {};

  /// Start timing an operation (e.g. 'signup', 'upload', 'page_load')
  void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// Stop timing and log duration. Returns elapsed milliseconds.
  int endTimer(String name) {
    final sw = _timers.remove(name);
    if (sw == null) return 0;
    sw.stop();
    final ms = sw.elapsedMilliseconds;
    _track('${name}_duration', {'duration_ms': ms});
    return ms;
  }

  void trackSignupCompleted({required String method}) {
    final durationMs = endTimer('signup');
    _track('signup_completed', {'method': method, if (durationMs > 0) 'duration_ms': durationMs});
  }

  void trackPhotoUploaded({required String photoId, bool isFilm = false}) {
    final durationMs = endTimer('upload');
    _track('photo_uploaded', {'photo_id': photoId, 'is_film': isFilm, if (durationMs > 0) 'duration_ms': durationMs});
  }

  void trackPhotoLiked({required String photoId}) {
    _track('photo_liked', {'photo_id': photoId});
  }

  void trackProfileViewed({required String username}) {
    _track('profile_viewed', {'username': username});
  }

  void trackSearchPerformed({required String query}) {
    _track('search_performed', {'query_length': query.length});
  }

  void trackPhotoViewed({required String photoId}) {
    _track('photo_viewed', {'photo_id': photoId});
  }

  void trackPageLoad({required String route, required int durationMs}) {
    _track('page_load', {'route': route, 'duration_ms': durationMs});
  }

  void _track(String event, [Map<String, dynamic>? properties]) {
    AppLogger.info('analytics: $event', properties);

    // TODO: Forward to external analytics in production:
    // - Vercel Analytics: custom events via vercel_analytics package
    // - Supabase: insert into `events` table
    // - Sentry Performance: transactions
  }
}
