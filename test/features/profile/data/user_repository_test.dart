import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:luxlog/features/profile/data/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuthClient;
  late UserRepository repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);
    repository = UserRepository(mockSupabaseClient);
  });

  test('followUser throws network exception when unauthenticated', () async {
    when(() => mockAuthClient.currentUser).thenReturn(null);

    expect(
      () => repository.followUser('target-id'),
      throwsA(isA<NetworkException>()),
    );
  });
}
