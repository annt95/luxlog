import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/rate_limiter.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  Future<Map<String, dynamic>> fetchProfile(String username) async {
    try {
      final response = await _client
          .from('profiles')
          .select('*, followers:follows!following_id(count), following:follows!follower_id(count)')
          .eq('username', username)
          .single();
      return response;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải hồ sơ người dùng (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải hồ sơ người dùng',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>> fetchCurrentProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
      final response = await _client
          .from('profiles')
          .select('*, followers:follows!following_id(count), following:follows!follower_id(count)')
          .eq('id', userId)
          .single();
      return response;
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải hồ sơ hiện tại (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải hồ sơ hiện tại',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String> resolveUserIdByUsername(String username) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .single();
      return response['id'] as String;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Không tìm thấy người dùng (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Không tìm thấy người dùng',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateProfile({String? fullName, String? bio, String? avatarUrl, Map<String, dynamic>? links}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
      
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (bio != null) updates['bio'] = bio;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (links != null) updates['links'] = links;
      
      await _client.from('profiles').update(updates).eq('id', userId);
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi cập nhật hồ sơ (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi cập nhật hồ sơ',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> followUser(String targetId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
      if (targetId == userId) return; // prevent self-follow
      if (!RateLimiter.canProceed('follow_${targetId}_$userId', const Duration(seconds: 1))) {
        throw const ValidationException('Thao tác quá nhanh, vui lòng chờ một lát.');
      }
      await _client.from('follows').insert({
        'follower_id': userId,
        'following_id': targetId,
      });
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi theo dõi người dùng (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi theo dõi người dùng',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> unfollowUser(String targetId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw AuthException('Vui lòng đăng nhập để thực hiện thao tác này');
      if (!RateLimiter.canProceed('unfollow_${targetId}_$userId', const Duration(seconds: 1))) {
        throw const ValidationException('Thao tác quá nhanh, vui lòng chờ một lát.');
      }
      await _client.from('follows').delete().match({
        'follower_id': userId,
        'following_id': targetId,
      });
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi bỏ theo dõi người dùng (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi bỏ theo dõi người dùng',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchFollowers(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('profiles!follower_id(*)')
          .eq('following_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải danh sách người theo dõi (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải danh sách người theo dõi',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchFollowing(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('profiles!following_id(*)')
          .eq('follower_id', userId);
      return List<Map<String, dynamic>>.from(response);
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải danh sách đang theo dõi (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi tải danh sách đang theo dõi',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }
}
