import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException, StorageException;
import '../../../../core/errors/app_exception.dart';

class PhotoRepository {
  final SupabaseClient _client;

  PhotoRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchFeed({required int page, required int limit, String? tab}) async {
    try {
      final response = await _client
          .from('photos')
          .select('*, profiles!photos_user_id_fkey(username, avatar_url, full_name)')
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải danh sách ảnh (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải danh sách ảnh',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchByUser({
    required String userId,
    required int page,
    int limit = 30,
  }) async {
    try {
      final response = await _client
          .from('photos')
          .select('*, profiles!photos_user_id_fkey(username, avatar_url, full_name)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải ảnh của người dùng (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải ảnh của người dùng',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> countByUser(String userId) async {
    try {
      final response = await _client
          .from('photos')
          .select('id')
          .eq('user_id', userId);
      return response.length;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi đếm số ảnh (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi đếm số ảnh',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<int> totalViewsByUser(String userId) async {
    try {
      final response = await _client
          .from('photos')
          .select('views_count')
          .eq('user_id', userId);
      var total = 0;
      for (final row in response) {
        total += (row['views_count'] as int?) ?? 0;
      }
      return total;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải lượt xem (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải lượt xem',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>> fetchPhotoById(String id) async {
    try {
      final response = await _client
          .from('photos')
          .select('*, profiles!photos_user_id_fkey(username, avatar_url, full_name), comments(*, profiles!comments_user_id_fkey(username, avatar_url, full_name))')
          .eq('id', id)
          .single();
      return response;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải thông tin ảnh (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải thông tin ảnh',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Upload photo: bytes → Supabase Storage → DB row
  /// Returns the new photo ID.
  Future<String> uploadPhoto({
    required Uint8List fileBytes,
    required String fileName,
    required String title,
    String? caption,
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
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthException('Vui lòng đăng nhập để tải ảnh');

    // Validate file type before any upload
    const allowedExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'};
    final ext = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(ext)) {
      throw ValidationException(
        'Unsupported file type: .$ext. Allowed: ${allowedExtensions.join(', ')}',
      );
    }

    try {
      // 1. Determine file extension from name (already validated above)
      final storagePath = 'uploads/$userId/${DateTime.now().millisecondsSinceEpoch}.$ext';

      // Fix MIME type for .jpg (Supabase expects 'image/jpeg' and rejects 'image/jpg' with 400 Bad Request)
      final String mimeType = (ext == 'jpg') ? 'image/jpeg' : 'image/$ext';

      // 2. Upload to Supabase Storage bucket "photos"
      await _client.storage.from('photos').uploadBinary(
        storagePath,
        fileBytes,
        fileOptions: FileOptions(contentType: mimeType),
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

      return photoId;
    } on PostgrestException catch (e, stackTrace) {
      throw StorageException(
        'Lỗi lưu metadata ảnh (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      if (e is AuthException) rethrow;
      throw StorageException(
        'Lỗi tải ảnh lên. Vui lòng thử lại.',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> likePhoto(String photoId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
      await _client.from('likes').insert({'photo_id': photoId, 'user_id': userId});
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi thích ảnh (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi thích ảnh', cause: e, stackTrace: stackTrace);
    }
  }

  Future<void> unlikePhoto(String photoId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
      await _client.from('likes').delete().match({'photo_id': photoId, 'user_id': userId});
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi bỏ thích ảnh (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi bỏ thích ảnh',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> hasLiked(String photoId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final response = await _client
          .from('likes')
          .select('photo_id')
          .eq('photo_id', photoId)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isFollowing(String targetUserId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final response = await _client
          .from('follows')
          .select('follower_id')
          .eq('follower_id', userId)
          .eq('following_id', targetUserId)
          .maybeSingle();
      return response != null;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchFollowingFeed({required int page, int limit = 20}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final followingIds = await _client
          .from('follows')
          .select('following_id')
          .eq('follower_id', userId);
      final ids = followingIds.map((r) => r['following_id'] as String).toList();
      if (ids.isEmpty) return [];
      final response = await _client
          .from('photos')
          .select('*, profiles!photos_user_id_fkey(username, avatar_url, full_name)')
          .inFilter('user_id', ids)
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải feed theo dõi (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tải feed theo dõi', cause: e, stackTrace: stackTrace);
    }
  }

  Future<List<Map<String, dynamic>>> fetchTopLiked({int limit = 10}) async {
    try {
      final response = await _client
          .from('photos')
          .select('*, profiles!photos_user_id_fkey(username, avatar_url, full_name)')
          .order('likes_count', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải ảnh nổi bật (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tải ảnh nổi bật', cause: e, stackTrace: stackTrace);
    }
  }

  Future<void> addComment(String photoId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Comment cannot be empty');
    }
    if (trimmed.length > 1000) {
      throw const ValidationException('Comment must be under 1000 characters');
    }
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
      await _client.from('comments').insert({
        'photo_id': photoId,
        'user_id': userId,
        'text': trimmed,
      });
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi gửi bình luận (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi gửi bình luận',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> savePhoto(String photoId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
    try {
      await _client.from('saves').insert({'photo_id': photoId, 'user_id': userId});
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException('Lỗi lưu ảnh (${e.code ?? 'unknown'})', cause: e, stackTrace: stackTrace);
    }
  }

  Future<void> unsavePhoto(String photoId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
    try {
      await _client.from('saves').delete().match({'photo_id': photoId, 'user_id': userId});
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException('Lỗi bỏ lưu ảnh (${e.code ?? 'unknown'})', cause: e, stackTrace: stackTrace);
    }
  }

  Future<bool> hasSaved(String photoId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final response = await _client
          .from('saves')
          .select('photo_id')
          .eq('photo_id', photoId)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchSavedPhotos({int page = 0, int limit = 20}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final response = await _client
          .from('saves')
          .select('photo_id, photos!inner(*, profiles!photos_user_id_fkey(username, avatar_url, full_name))')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(page * limit, (page + 1) * limit - 1);
      return List<Map<String, dynamic>>.from(
        response.map((r) => r['photos'] as Map<String, dynamic>),
      );
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException('Lỗi tải ảnh đã lưu (${e.code ?? 'unknown'})', cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tải ảnh đã lưu', cause: e, stackTrace: stackTrace);
    }
  }
}
