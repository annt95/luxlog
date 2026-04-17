import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/user_repository.dart';
import '../../../core/services/supabase_service.dart';

part 'user_provider.g.dart';

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository(SupabaseService.client);
}

@riverpod
Future<Map<String, dynamic>> userProfile(UserProfileRef ref, String username) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.fetchProfile(username);
}
