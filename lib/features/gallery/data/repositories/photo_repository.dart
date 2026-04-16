import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';

class PhotoRepository {
  final SupabaseClient _client;

  PhotoRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchFeed({required int page, required int limit, String? tab}) async {
    try {
      final response = await _client
          .from('photos')
          .select('*, profiles(username, avatar_url)')
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw const NetworkException('Lỗi tải danh sách ảnh');
    }
  }

  Future<Map<String, dynamic>> fetchPhotoById(String id) async {
    try {
      final response = await _client
          .from('photos')
          .select('*, profiles(username, avatar_url), comments(*, profiles(username, avatar_url))')
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      throw const NetworkException('Lỗi tải thông tin ảnh');
    }
  }

  Future<void> uploadPhoto({required String filePath, required String title, Map<String, dynamic>? exif}) async {
    // Placeholder implementation for upload
    try {
      // 1. Upload to storage
      // 2. Insert into DB
    } catch (e) {
      throw const StorageException('Lỗi tải ảnh lên');
    }
  }

  Future<void> likePhoto(String photoId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException();
      await _client.from('likes').insert({'photo_id': photoId, 'user_id': userId});
    } catch (e) {
      throw const NetworkException('Lỗi thích ảnh');
    }
  }

  Future<void> unlikePhoto(String photoId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException();
      await _client.from('likes').delete().match({'photo_id': photoId, 'user_id': userId});
    } catch (e) {
      throw const NetworkException('Lỗi bỏ thích ảnh');
    }
  }

  Future<void> addComment(String photoId, String text) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException();
      await _client.from('comments').insert({
        'photo_id': photoId,
        'user_id': userId,
        'text': text,
      });
    } catch (e) {
      throw const NetworkException('Lỗi gửi bình luận');
    }
  }
}
