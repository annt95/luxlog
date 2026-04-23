import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioRepository {
  final SupabaseClient _client;

  PortfolioRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchPortfoliosByUser(String userId) async {
    try {
      final response = await _client
          .from('portfolios')
          .select('*')
          .eq('user_id', userId)
          .eq('is_public', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return PortfolioRepository(Supabase.instance.client);
});

final userPortfoliosProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.fetchPortfoliosByUser(userId);
});
