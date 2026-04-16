import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

  Future<Map<String, dynamic>> fetchProfile(String username) async {
    try {
      final response = await _client
          .from('profiles')
          .select('*, followers:follows!following_id(count), following:follows!follower_id(count)')
          .eq('username', username)
          .single();
      return response;
    } catch (e) {
      throw const NetworkException('Lỗi tải hồ sơ người dùng');
    }
  }

  Future<void> updateProfile({String? bio, String? avatarUrl, Map<String, dynamic>? links}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException();
      
      final updates = <String, dynamic>{};
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (links != null) updates['links'] = links;
      
      await _client.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw const NetworkException('Lỗi cập nhật hồ sơ');
    }
  }

  Future<void> followUser(String targetId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException();
      await _client.from('follows').insert({
        'follower_id': userId,
        'following_id': targetId,
      });
    } catch (e) {
      throw const NetworkException('Lỗi theo dõi người dùng');
    }
  }

  Future<void> unfollowUser(String targetId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw const AuthException();
      await _client.from('follows').delete().match({
        'follower_id': userId,
        'following_id': targetId,
      });
    } catch (e) {
      throw const NetworkException('Lỗi bỏ theo dõi người dùng');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFollowers(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('profiles!follower_id(*)')
          .eq('following_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw const NetworkException('Lỗi tải danh sách người theo dõi');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFollowing(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('profiles!following_id(*)')
          .eq('follower_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw const NetworkException('Lỗi tải danh sách đang theo dõi');
    }
  }
}
