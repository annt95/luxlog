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

  // Email/Password
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
      throw UnknownException(cause: e, stackTrace: stackTrace);
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
      throw UnknownException(cause: e, stackTrace: stackTrace);
    }
  }

  // Social OAuth
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(OAuthProvider.google);
      final user = _client.auth.currentUser;
      if (user != null) {
        await _remoteDataSource.syncUserProfile(user);
      }
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw AuthException(
        'Google sign in failed',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      await _client.auth.signInWithOAuth(OAuthProvider.facebook);
      final user = _client.auth.currentUser;
      if (user != null) {
        await _remoteDataSource.syncUserProfile(user);
      }
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw AuthException(
        'Facebook sign in failed',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Session
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw AuthException('Sign out failed', cause: e, stackTrace: stackTrace);
    }
  }

  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on supa.AuthException catch (e, stackTrace) {
      throw AuthException(e.message, cause: e, stackTrace: stackTrace);
    } catch (e, stackTrace) {
      throw UnknownException(cause: e, stackTrace: stackTrace);
    }
  }
}
