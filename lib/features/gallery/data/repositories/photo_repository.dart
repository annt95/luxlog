import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException, StorageException;
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

  /// Upload photo: bytes → Supabase Storage → DB row
  /// Returns the new photo ID.
  Future<String> uploadPhoto({
    required Uint8List fileBytes,
    required String fileName,
    required String title,
    String? caption,
    String? license,
    bool allowDownload = true,
    // EXIF (auto-parsed or manual for film)
    bool isFilm = false,
    String? filmStock,
    String? filmCamera,
    String? camera,
    String? lens,
    int? iso,
    String? aperture,
    String? shutterSpeed,
    double? focalLength,
    double? latitude,
    double? longitude,
    bool shareGps = false,
    // Tags & categories
    List<String> tagNames = const [],
    List<String> categoryIds = const [],
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('Vui lòng đăng nhập để tải ảnh');

    try {
      // 1. Determine file extension from name
      final ext = fileName.split('.').last.toLowerCase();
      final storagePath = 'uploads/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      // 2. Upload to Supabase Storage bucket "photos"
      await _client.storage.from('photos').uploadBinary(
        storagePath,
        fileBytes,
        fileOptions: FileOptions(contentType: 'image/$ext'),
      );

      // 3. Get public URL
      final imageUrl = _client.storage.from('photos').getPublicUrl(storagePath);

      // 4. Build row data
      final row = <String, dynamic>{
        'user_id': userId,
        'title': title.isNotEmpty ? title : null,
        'caption': caption?.isNotEmpty == true ? caption : null,
        'description': caption, // alias
        'image_url': imageUrl,
        'camera': camera,
        'lens': lens,
        'iso': iso,
        'aperture': aperture,
        'shutter_speed': shutterSpeed,
        'focal_length': focalLength?.toString(),
        'license': license ?? 'CC BY 4.0',
        'allow_download': allowDownload,
        'is_film': isFilm,
        'film_stock': isFilm ? filmStock : null,
        'film_camera': isFilm ? filmCamera : null,
        'is_public': true,
      };

      // Only store GPS if user explicitly opted in
      if (shareGps && latitude != null && longitude != null) {
        row['latitude'] = latitude;
        row['longitude'] = longitude;
      }

      // 5. Insert into photos table
      final response = await _client
          .from('photos')
          .insert(row)
          .select('id')
          .single();

      final photoId = response['id'] as String;

      // 6. Attach tags (upsert tag names → get IDs → link)
      for (final tagName in tagNames) {
        try {
          final tagId = await _client.rpc('increment_tag_usage', params: {'tag_name': tagName});
          await _client.from('photo_tags').insert({
            'photo_id': photoId,
            'tag_id': tagId,
          });
        } catch (_) {
          // Non-critical: skip tag if it fails
        }
      }

      // 7. Attach categories
      if (categoryIds.isNotEmpty) {
        final catRows = categoryIds.map((catId) => {
          'photo_id': photoId,
          'category_id': catId,
        }).toList();
        try {
          await _client.from('photo_categories').upsert(catRows);
        } catch (_) {
          // Non-critical
        }
      }

      return photoId;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const StorageException('Lỗi tải ảnh lên. Vui lòng thử lại.');
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
