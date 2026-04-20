import 'logger.dart';

/// Lightweight analytics service for tracking key user funnels.
/// In v1: logs events locally. Can be extended to Vercel Analytics,
/// Supabase events table, or any third-party analytics provider.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  void trackSignupCompleted({required String method}) {
    _track('signup_completed', {'method': method});
  }

  void trackPhotoUploaded({required String photoId, bool isFilm = false}) {
    _track('photo_uploaded', {'photo_id': photoId, 'is_film': isFilm});
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

  void _track(String event, [Map<String, dynamic>? properties]) {
    AppLogger.info('analytics: $event', properties);

    // TODO: Forward to external analytics in production:
    // - Vercel Analytics: custom events via vercel_analytics package
    // - Supabase: insert into `events` table
    // - PostHog / Mixpanel / Amplitude
  }
}
