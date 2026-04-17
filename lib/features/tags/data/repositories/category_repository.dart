import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  /// Get all categories ordered by display_order
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('display_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw const NetworkException('Lỗi tải danh mục');
    }
  }

  /// Get photos by category slug (paginated)
  Future<List<Map<String, dynamic>>> getPhotosByCategory(
    String slug, {
    required int page,
    int limit = 20,
  }) async {
    try {
      // Find category
      final catResponse = await _client
          .from('categories')
          .select('id')
          .eq('slug', slug)
          .maybeSingle();

      if (catResponse == null) return [];

      final catId = catResponse['id'] as String;
      final response = await _client
          .from('photo_categories')
          .select('photos(*, users(username, avatar_url))')
          .eq('category_id', catId)
          .range(page * limit, (page + 1) * limit - 1);

      return List<Map<String, dynamic>>.from(
        response.map((r) => r['photos'] as Map<String, dynamic>),
      );
    } catch (e) {
      throw const NetworkException('Lỗi tải ảnh theo danh mục');
    }
  }

  /// Get categories for a specific photo
  Future<List<Map<String, dynamic>>> getCategoriesByPhoto(String photoId) async {
    try {
      final response = await _client
          .from('photo_categories')
          .select('categories(*)')
          .eq('photo_id', photoId);
      return List<Map<String, dynamic>>.from(
        response.map((r) => r['categories'] as Map<String, dynamic>),
      );
    } catch (e) {
      throw const NetworkException('Lỗi tải danh mục của ảnh');
    }
  }

  /// Attach categories to a photo
  Future<void> attachCategoriesToPhoto(String photoId, List<String> categoryIds) async {
    try {
      final rows = categoryIds.map((catId) => {
        'photo_id': photoId,
        'category_id': catId,
      }).toList();

      await _client.from('photo_categories').upsert(rows);
    } catch (e) {
      throw const NetworkException('Lỗi gắn danh mục cho ảnh');
    }
  }
}
