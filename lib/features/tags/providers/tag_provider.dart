import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/tag_repository.dart';
import '../../../core/services/supabase_service.dart';

part 'tag_provider.g.dart';

@riverpod
TagRepository tagRepository(TagRepositoryRef ref) {
  return TagRepository(SupabaseService.client);
}

@riverpod
Future<List<Map<String, dynamic>>> searchTags(SearchTagsRef ref, String query) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.searchTags(query);
}

@riverpod
Future<List<Map<String, dynamic>>> trendingTags(TrendingTagsRef ref) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getTrendingTags();
}

@riverpod
Future<List<Map<String, dynamic>>> photoTags(PhotoTagsRef ref, String photoId) {
  final repository = ref.watch(tagRepositoryProvider);
  return repository.getTagsByPhoto(photoId);
}
