import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';

class TagRepository {
  final SupabaseClient _client;

  static const int maxTagsPerPhoto = 30;
  static const int maxTagLength = 50;

  TagRepository(this._client);

  /// Search tags by prefix (autocomplete)
  Future<List<Map<String, dynamic>>> searchTags(String query) async {
    try {
      if (query.trim().isEmpty) return [];
      final response = await _client
          .from('tags')
          .select()
          .ilike('name', '${query.trim().toLowerCase()}%')
          .order('usage_count', ascending: false)
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tìm kiếm tag (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tìm kiếm tag', cause: e, stackTrace: stackTrace);
    }
  }

  /// Get trending tags sorted by usage_count
  Future<List<Map<String, dynamic>>> getTrendingTags({int limit = 20}) async {
    try {
      final response = await _client
          .from('tags')
          .select()
          .gt('usage_count', 0)
          .order('usage_count', ascending: false)
          .limit(limit);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải trending tags (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải trending tags',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get tags for a specific photo
  Future<List<Map<String, dynamic>>> getTagsByPhoto(String photoId) async {
    try {
      final response = await _client
          .from('photo_tags')
          .select('tags(*)')
          .eq('photo_id', photoId);
      return List<Map<String, dynamic>>.from(
        response.map((r) => r['tags'] as Map<String, dynamic>),
      );
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải tags của ảnh (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải tags của ảnh',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get photos by tag name (paginated)
  Future<List<Map<String, dynamic>>> getPhotosByTag(
    String tagName, {
    required int page,
    int limit = 20,
  }) async {
    try {
      // First find the tag
      final tagResponse = await _client
          .from('tags')
          .select('id')
          .eq('name', tagName.toLowerCase())
          .maybeSingle();

      if (tagResponse == null) return [];

      final tagId = tagResponse['id'] as String;
      final response = await _client
          .from('photo_tags')
          .select('photos(*, profiles(username, avatar_url))')
          .eq('tag_id', tagId)
          .range(page * limit, (page + 1) * limit - 1);

      return List<Map<String, dynamic>>.from(
        response.map((r) => r['photos'] as Map<String, dynamic>),
      );
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải ảnh theo tag (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tải ảnh theo tag', cause: e, stackTrace: stackTrace);
    }
  }

  /// Attach multiple tags to a photo (upsert + increment usage)
  Future<void> attachTagsToPhoto(String photoId, List<String> tagNames) async {
    if (tagNames.length > maxTagsPerPhoto) {
      throw ValidationException('Maximum $maxTagsPerPhoto tags per photo');
    }
    try {
      for (final name in tagNames) {
        final cleanName = name.trim().toLowerCase().replaceAll('#', '');
        if (cleanName.isEmpty) continue;
        if (cleanName.length > maxTagLength) continue; // skip oversized tags

        // Upsert tag and get ID via RPC
        final tagId = await _client.rpc('increment_tag_usage', params: {
          'tag_name': cleanName,
        });

        // Create association
        await _client.from('photo_tags').upsert({
          'photo_id': photoId,
          'tag_id': tagId,
        });
      }
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi gắn tag cho ảnh (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi gắn tag cho ảnh', cause: e, stackTrace: stackTrace);
    }
  }

  /// Parse hashtags from caption text (e.g. "Beautiful sunset #goldenhour #landscape")
  static List<String> parseHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }
}
