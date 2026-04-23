import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/photo_repository.dart';
import 'photo_provider.dart';

// ── State ────────────────────────────────────────────────────────────────────

@immutable
class PaginatedFeedState {
  final List<Map<String, dynamic>> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  const PaginatedFeedState({
    this.items = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PaginatedFeedState copyWith({
    List<Map<String, dynamic>>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedFeedState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

// ── "For You" Feed Notifier ──────────────────────────────────────────────────

class PaginatedFeedNotifier extends StateNotifier<AsyncValue<PaginatedFeedState>> {
  final PhotoRepository _repo;
  final int _pageSize;
  final String? _tab;

  PaginatedFeedNotifier(this._repo, {int pageSize = 24, String? tab})
      : _pageSize = pageSize,
        _tab = tab,
        super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.fetchFeed(page: 0, limit: _pageSize, tab: _tab);
      state = AsyncValue.data(PaginatedFeedState(
        items: items,
        currentPage: 0,
        hasMore: items.length >= _pageSize,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final newItems = await _repo.fetchFeed(page: nextPage, limit: _pageSize, tab: _tab);
      state = AsyncValue.data(current.copyWith(
        items: [...current.items, ...newItems],
        currentPage: nextPage,
        hasMore: newItems.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      // Keep existing data, just stop loading
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      debugPrint('[PaginatedFeed] loadMore error: $e');
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

// ── "Following" Feed Notifier ────────────────────────────────────────────────

class PaginatedFollowFeedNotifier extends StateNotifier<AsyncValue<PaginatedFeedState>> {
  final PhotoRepository _repo;
  final int _pageSize;

  PaginatedFollowFeedNotifier(this._repo, {int pageSize = 20})
      : _pageSize = pageSize,
        super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.fetchFollowingFeed(page: 0, limit: _pageSize);
      state = AsyncValue.data(PaginatedFeedState(
        items: items,
        currentPage: 0,
        hasMore: items.length >= _pageSize,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final newItems = await _repo.fetchFollowingFeed(page: nextPage, limit: _pageSize);
      state = AsyncValue.data(current.copyWith(
        items: [...current.items, ...newItems],
        currentPage: nextPage,
        hasMore: newItems.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      debugPrint('[PaginatedFollowFeed] loadMore error: $e');
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

// ── Discover Feed Notifier ───────────────────────────────────────────────────

class PaginatedDiscoverNotifier extends StateNotifier<AsyncValue<PaginatedFeedState>> {
  final PhotoRepository _repo;
  final int _pageSize;

  PaginatedDiscoverNotifier(this._repo, {int pageSize = 24})
      : _pageSize = pageSize,
        super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.fetchFeed(page: 0, limit: _pageSize);
      state = AsyncValue.data(PaginatedFeedState(
        items: items,
        currentPage: 0,
        hasMore: items.length >= _pageSize,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final newItems = await _repo.fetchFeed(page: nextPage, limit: _pageSize);
      state = AsyncValue.data(current.copyWith(
        items: [...current.items, ...newItems],
        currentPage: nextPage,
        hasMore: newItems.length >= _pageSize,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncValue.data(current.copyWith(isLoadingMore: false));
      debugPrint('[PaginatedDiscover] loadMore error: $e');
    }
  }

  Future<void> refresh() async {
    await loadInitial();
  }
}

// ── Providers ────────────────────────────────────────────────────────────────

final paginatedFeedProvider =
    StateNotifierProvider.autoDispose<PaginatedFeedNotifier, AsyncValue<PaginatedFeedState>>((ref) {
  final repo = ref.watch(photoRepositoryProvider);
  return PaginatedFeedNotifier(repo, pageSize: 10, tab: 'for-you');
});

final paginatedFollowFeedProvider =
    StateNotifierProvider.autoDispose<PaginatedFollowFeedNotifier, AsyncValue<PaginatedFeedState>>((ref) {
  final repo = ref.watch(photoRepositoryProvider);
  return PaginatedFollowFeedNotifier(repo, pageSize: 10);
});

final paginatedDiscoverProvider =
    StateNotifierProvider.autoDispose<PaginatedDiscoverNotifier, AsyncValue<PaginatedFeedState>>((ref) {
  final repo = ref.watch(photoRepositoryProvider);
  return PaginatedDiscoverNotifier(repo, pageSize: 24);
});
