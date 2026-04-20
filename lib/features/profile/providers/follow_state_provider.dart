import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'user_provider.dart';

part 'follow_state_provider.g.dart';

@riverpod
class FollowState extends _$FollowState {
  @override
  Set<String> build() {
    _loadFollowing();
    return <String>{};
  }

  Future<void> _loadFollowing() async {
    final repository = ref.read(userRepositoryProvider);
    final currentUser = repository.currentUser;
    if (currentUser == null) return;

    try {
      final rows = await repository.fetchFollowing(currentUser.id);
      final usernames = rows
          .map((row) => row['profiles'] as Map<String, dynamic>?)
          .whereType<Map<String, dynamic>>()
          .map((profile) => profile['username'] as String?)
          .whereType<String>()
          .toSet();
      state = usernames;
    } catch (_) {
      // Keep last known state on load failure.
    }
  }

  Future<void> toggleFollow(String username) async {
    final repository = ref.read(userRepositoryProvider);
    final wasFollowing = state.contains(username);

    // Optimistic update.
    state = wasFollowing ? ({...state}..remove(username)) : {...state, username};
    try {
      final targetId = await repository.resolveUserIdByUsername(username);
      if (wasFollowing) {
        await repository.unfollowUser(targetId);
      } else {
        await repository.followUser(targetId);
      }
      ref.invalidate(currentUserProfileProvider);
    } catch (_) {
      // Roll back on failure.
      state = wasFollowing ? {...state, username} : ({...state}..remove(username));
      rethrow;
    }
  }
}
