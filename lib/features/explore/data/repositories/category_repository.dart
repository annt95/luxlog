import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('*')
          .eq('status', 'approved')
          .order('display_order', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(Supabase.instance.client);
});

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.fetchCategories();
});
