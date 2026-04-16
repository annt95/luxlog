import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';

class AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSource(this._client);

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
          'username': displayName.toLowerCase().replaceAll(' ', '') + user.id.substring(0, 4),
          'display_name': displayName,
          'avatar_url': avatarUrl,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw const NetworkException('Lỗi đồng bộ hồ sơ người dùng');
    }
  }
}
