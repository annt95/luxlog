import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/photo_repository.dart';
import '../../../core/services/supabase_service.dart';

part 'photo_provider.g.dart';

@riverpod
PhotoRepository photoRepository(PhotoRepositoryRef ref) {
  return PhotoRepository(SupabaseService.client);
}

@riverpod
Future<List<Map<String, dynamic>>> photoFeed(PhotoFeedRef ref, {int page = 0, int limit = 20, String? tab}) {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.fetchFeed(page: page, limit: limit, tab: tab);
}

@riverpod
Future<Map<String, dynamic>> photoDetail(PhotoDetailRef ref, String photoId) {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.fetchPhotoById(photoId);
}
