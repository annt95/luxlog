import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository.dart';
import '../../../../core/services/supabase_service.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(
    SupabaseService.client,
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
}

@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSource(SupabaseService.client);
}

@riverpod
Stream<AuthState> authState(AuthStateRef ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  final authStateAsync = ref.watch(authStateProvider);
  return authStateAsync.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
}

/// Listens to auth state changes and auto-syncs user profile on sign-in.
///
/// This handles both email/password sign-in AND Google OAuth return,
/// ensuring [AuthRemoteDataSource.syncUserProfile] is always called
/// after a successful authentication regardless of the provider.
@riverpod
void authProfileSync(AuthProfileSyncRef ref) {
  final datasource = ref.watch(authRemoteDataSourceProvider);

  ref.listen(authStateProvider, (_, next) {
    next.whenData((state) async {
      if (state.event == AuthChangeEvent.signedIn && state.session?.user != null) {
        try {
          await datasource.syncUserProfile(state.session!.user);
        } catch (_) {
          // Profile sync is best-effort; do not block the login flow.
        }
      }
    });
  });
}
