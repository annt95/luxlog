import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luxlog/features/auth/data/repositories/auth_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuthClient;
  late AuthRepository authRepository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);
    authRepository = AuthRepository(mockSupabaseClient);
  });

  group('AuthRepository', () {
    test('signUp returns AuthResponse on success', () async {
      final mockResponse = MockAuthResponse();
      when(() => mockAuthClient.signUp(
            email: 'test@example.com',
            password: 'password123',
            data: {'display_name': 'Test User'},
          )).thenAnswer((_) async => mockResponse);

      final result = await authRepository.signUp(
        email: 'test@example.com',
        password: 'password123',
        displayName: 'Test User',
      );

      expect(result, isA<AuthResponse>());
      verify(() => mockAuthClient.signUp(
            email: 'test@example.com',
            password: 'password123',
            data: {'display_name': 'Test User'},
          )).called(1);
    });

    test('signUp throws AppException on AuthException', () async {
      when(() => mockAuthClient.signUp(
            email: 'test@example.com',
            password: 'password123',
            data: {'display_name': 'Test User'},
          )).thenThrow(const AuthException('Sign up failed'));

      expect(
        () => authRepository.signUp(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        ),
        throwsA(isA<AppException>().having((e) => e.message, 'message', 'Sign up failed')),
      );
    });
    
    test('signIn returns AuthResponse on success', () async {
      final mockResponse = MockAuthResponse();
      when(() => mockAuthClient.signInWithPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => mockResponse);

      final result = await authRepository.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<AuthResponse>());
    });
  });
}
