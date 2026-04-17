import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthException;
import '../../../../core/errors/app_exception.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

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
      return response;
    } on supa.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException();
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
    } on supa.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException();
    }
  }

  // Social OAuth
  Future<void> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      throw AuthException('Google sign in failed');
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      await _client.auth.signInWithOAuth(OAuthProvider.facebook);
    } catch (e) {
      throw AuthException('Facebook sign in failed');
    }
  }

  // Session
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed');
    }
  }

  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on supa.AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw UnknownException();
    }
  }
}
