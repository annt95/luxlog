import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthException;
import '../../../../core/errors/app_exception.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepository {
  final SupabaseClient _client;
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository(
    this._client, {
    AuthRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(_client);

  // ── Email/Password ──────────────────────────────────────────────────────────

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );
      final user = response.user ?? _client.auth.currentUser;
      if (user != null) {
        await _remoteDataSource.syncUserProfile(user);
      }
      return response;
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw UnknownException('Đã xảy ra lỗi không xác định', cause: e, stackTrace: stackTrace);
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw UnknownException('Đã xảy ra lỗi không xác định', cause: e, stackTrace: stackTrace);
    }
  }

  // ── Social OAuth ────────────────────────────────────────────────────────────

  /// Signs in with Google using OAuth redirect flow.
  ///
  /// On Web: triggers a full-page redirect to Google → back to [_getRedirectUrl()].
  /// The Supabase JS SDK auto-parses tokens from the URL hash on return.
  /// Profile sync is handled by the auth state listener in [auth_provider.dart].
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _getRedirectUrl(),
      );
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw AuthException(
        'Đăng nhập Google không thành công. Vui lòng thử lại.',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Returns the OAuth redirect URL for the current platform.
  ///
  /// On Web: uses [Uri.base.origin] so Supabase redirects back to the app.
  /// On native mobile: returns null (deep-link will be configured separately).
  String? _getRedirectUrl() {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    return null;
  }

  // ── Session ─────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw AuthException('Đăng xuất không thành công', cause: e, stackTrace: stackTrace);
    }
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Password reset ──────────────────────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw UnknownException('Đã xảy ra lỗi không xác định', cause: e, stackTrace: stackTrace);
    }
  }
}
