import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSource(this._client);

  String _buildUsername({
    required String displayName,
    required String userId,
  }) {
    final normalized = displayName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    final base = normalized.isEmpty ? 'user' : normalized;
    final suffixLength = userId.length < 8 ? userId.length : 8;
    return '$base${userId.substring(0, suffixLength)}';
  }

  Future<void> syncUserProfile(User user) async {
    try {
      final existingProfile = await _client
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile == null) {
        // Auto-sync
        final providerData = user.appMetadata['providers'] as List<dynamic>?;
        final isOAuth = providerData != null && providerData.any((p) => p != 'email');
        
        String displayName = user.email?.split('@').first ?? 'User';
        String? avatarUrl;
        
        if (isOAuth) {
          final metadata = user.userMetadata;
          if (metadata != null) {
            displayName = metadata['full_name'] ?? metadata['name'] ?? displayName;
            avatarUrl = metadata['avatar_url'] ?? metadata['picture'];
          }
        }

        await _client.from('profiles').insert({
          'id': user.id,
          'username': _buildUsername(
            displayName: displayName,
            userId: user.id,
          ),
          'email': user.email,
          'avatar_url': avatarUrl,
        });
      }
    } on PostgrestException catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi đồng bộ hồ sơ người dùng (${e.code ?? 'unknown'})',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw NetworkException(
        'Lỗi đồng bộ hồ sơ người dùng',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }
}
