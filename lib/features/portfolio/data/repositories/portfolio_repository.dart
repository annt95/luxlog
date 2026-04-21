import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';

class PortfolioRepository {
  final SupabaseClient _client;

  PortfolioRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchPortfolio(String userId) async {
    try {
      final response = await _client
          .from('portfolios')
          .select('blocks')
          .eq('user_id', userId)
          .maybeSingle();

      // No portfolio row exists yet → return empty
      if (response == null) return [];

      if (response['blocks'] is String) {
        return List<Map<String, dynamic>>.from(
          jsonDecode(response['blocks'] as String) as List<dynamic>,
        );
      }
      if (response['blocks'] is List) {
        return List<Map<String, dynamic>>.from(response['blocks'] as List);
      }
      return [];

    } on PostgrestException catch (e, stackTrace) {
      if (e.code == 'PGRST116') {
        // Not found, return empty portfolio
        return [];
      }
      throw NetworkException(
        'Lỗi tải portfolio (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tải portfolio', cause: e, stackTrace: stackTrace);
    }
  }

  Future<void> savePortfolio(String userId, List<Map<String, dynamic>> blocks) async {
    try {
      final blocksJson = jsonEncode(blocks);
      await _client.from('portfolios').upsert({
        'user_id': userId,
        'blocks': blocksJson,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi lưu portfolio (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi lưu portfolio', cause: e, stackTrace: stackTrace);
    }
  }

  Future<List<Map<String, dynamic>>> fetchPublicPortfolio(String slug) async {
    try {
      final userResponse = await _client
          .from('profiles')
          .select('id')
          .eq('username', slug)
          .single();
      
      final userId = userResponse['id'] as String;
      return await fetchPortfolio(userId);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải portfolio công khai (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải portfolio công khai',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserPortfolios(String userId) async {
    try {
      final response = await _client
          .from('portfolios')
          .select('id, title, slug, cover_image, is_public, blocks, created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response as List);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải danh sách portfolios (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tải danh sách portfolios', cause: e, stackTrace: stackTrace);
    }
  }

  Future<String> createPortfolio(String userId, String title) async {
    try {
      final response = await _client.from('portfolios').insert({
        'user_id': userId,
        'title': title,
        'is_public': false,
        'blocks': '[]',
      }).select('id').single();
      return response['id'] as String;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tạo portfolio (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi tạo portfolio', cause: e, stackTrace: stackTrace);
    }
  }

  Future<void> deletePortfolio(String portfolioId) async {
    try {
      await _client.from('portfolios').delete().eq('id', portfolioId);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi xóa portfolio (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi xóa portfolio', cause: e, stackTrace: stackTrace);
    }
  }

  Future<void> updatePortfolioMeta(String portfolioId, {String? title, String? slug, bool? isPublic}) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (slug != null) updates['slug'] = slug;
      if (isPublic != null) {
        updates['is_public'] = isPublic;
        // Track publish timestamp and increment version when making public
        if (isPublic) {
          updates['published_at'] = DateTime.now().toUtc().toIso8601String();
          // Increment version via raw SQL would be ideal, but for now set in app
        }
      }
      if (updates.isEmpty) return;
      await _client.from('portfolios').update(updates).eq('id', portfolioId);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi cập nhật portfolio (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException('Lỗi cập nhật portfolio', cause: e, stackTrace: stackTrace);
    }
  }
}
