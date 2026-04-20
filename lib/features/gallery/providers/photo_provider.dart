import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// ── Manual providers (avoid build_runner dependency) ─────────────────────────

final photoLikeStateProvider = FutureProvider.autoDispose.family<bool, String>((ref, photoId) {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.hasLiked(photoId);
});

final followStateProvider = FutureProvider.autoDispose.family<bool, String>((ref, targetUserId) {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.isFollowing(targetUserId);
});

final followingFeedProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, int>((ref, page) {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.fetchFollowingFeed(page: page);
});

final editorsPickProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final repository = ref.watch(photoRepositoryProvider);
  return repository.fetchTopLiked(limit: 10);
});
