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
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
}
