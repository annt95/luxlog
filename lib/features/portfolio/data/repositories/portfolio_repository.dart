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
          .single();
      
      if (response['blocks'] != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(response['blocks'] as String));
      }
      return [];
    } catch (e) {
      if (e is PostgrestException && e.code == 'PGRST116') {
        // Not found, return empty portfolio
        return [];
      }
      throw const NetworkException('Lỗi tải portfolio');
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
    } catch (e) {
      throw const NetworkException('Lỗi lưu portfolio');
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
    } catch (e) {
      throw const NetworkException('Lỗi tải portfolio công khai');
    }
  }
}
