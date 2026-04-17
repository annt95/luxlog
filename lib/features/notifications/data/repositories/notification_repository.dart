import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/app_exception.dart';

class NotificationRepository {
  final SupabaseClient _client;
  NotificationRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchNotifications(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select(
            '''
            *,
            actor:profiles!actor_id(username, avatar_url),
            photo:photos(id, image_url)
            ''',
          )
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(100);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải thông báo (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tải thông báo', cause: e, stackTrace: stackTrace);
    }
  }

  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', userId)
        .order('created_at', ascending: false)
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  Future<int> unreadCount(String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select('id')
          .eq('recipient_id', userId)
          .isFilter('read_at', null);
      return response.length;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải số thông báo chưa đọc (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải số thông báo chưa đọc',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'read_at': DateTime.now().toIso8601String()})
          .eq('recipient_id', userId)
          .isFilter('read_at', null);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi đánh dấu đã đọc (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi đánh dấu đã đọc', cause: e, stackTrace: stackTrace);
    }
  }
}
