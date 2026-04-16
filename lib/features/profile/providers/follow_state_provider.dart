import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'follow_state_provider.g.dart';

@riverpod
class FollowState extends _$FollowState {
  @override
  Set<String> build() {
    // Mock initial follows
    return {'sarahkwon', 'alexm'};
  }

  void toggleFollow(String username) {
    if (state.contains(username)) {
      state = {...state}..remove(username);
    } else {
      state = {...state}..add(username);
    }
  }

  bool isFollowing(String username) {
    return state.contains(username);
  }
}
