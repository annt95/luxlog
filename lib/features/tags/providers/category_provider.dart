import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/category_repository.dart';
import '../../../core/services/supabase_service.dart';

part 'category_provider.g.dart';

@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository(SupabaseService.client);
}

@riverpod
Future<List<Map<String, dynamic>>> categories(CategoriesRef ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories();
}

@riverpod
Future<List<Map<String, dynamic>>> categoryPhotos(
  CategoryPhotosRef ref,
  String slug, {
  int page = 0,
}) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getPhotosByCategory(slug, page: page);
}
