import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthException;
import 'package:luxlog/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:luxlog/features/auth/data/repositories/auth_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockAuthResponse extends Mock implements AuthResponse {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockAuthRemoteDataSource mockRemote;
  late AuthRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockRemote = MockAuthRemoteDataSource();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repository = AuthRepository(mockClient, remoteDataSource: mockRemote);
  });

  group('AuthRepository — provider layer', () {
    group('signIn', () {
      test('returns AuthResponse on valid credentials', () async {
        final mockResponse = MockAuthResponse();
        when(() => mockAuth.signInWithPassword(
              email: 'user@test.com',
              password: 'Pass1234',
            )).thenAnswer((_) async => mockResponse);

        final result = await repository.signIn(
          email: 'user@test.com',
          password: 'Pass1234',
        );
        expect(result, isA<AuthResponse>());
      });

      test('throws AuthException on invalid credentials', () async {
        when(() => mockAuth.signInWithPassword(
              email: 'user@test.com',
              password: 'wrong',
            )).thenThrow(
          const supa.AuthException('Invalid login credentials'),
        );

        expect(
          () => repository.signIn(email: 'user@test.com', password: 'wrong'),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws UnknownException on unexpected error', () async {
        when(() => mockAuth.signInWithPassword(
              email: 'user@test.com',
              password: 'Pass1234',
            )).thenThrow(Exception('socket timeout'));

        expect(
          () => repository.signIn(
              email: 'user@test.com', password: 'Pass1234'),
          throwsA(isA<UnknownException>()),
        );
      });
    });

    group('signUp', () {
      test('calls syncUserProfile after successful signup', () async {
        final mockResponse = MockAuthResponse();
        final mockUser = MockUser();

        when(() => mockAuth.signUp(
              email: 'new@test.com',
              password: 'Strong1234',
              data: {'display_name': 'New User'},
            )).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.user).thenReturn(mockUser);
        when(() => mockRemote.syncUserProfile(mockUser))
            .thenAnswer((_) async {});

        await repository.signUp(
          email: 'new@test.com',
          password: 'Strong1234',
          displayName: 'New User',
        );

        verify(() => mockRemote.syncUserProfile(mockUser)).called(1);
      });

      test('syncs profile using currentUser when response.user is null',
          () async {
        final mockResponse = MockAuthResponse();
        final mockUser = MockUser();

        when(() => mockAuth.signUp(
              email: 'new@test.com',
              password: 'Strong1234',
              data: {'display_name': 'Fallback'},
            )).thenAnswer((_) async => mockResponse);
        when(() => mockResponse.user).thenReturn(null);
        when(() => mockAuth.currentUser).thenReturn(mockUser);
        when(() => mockRemote.syncUserProfile(mockUser))
            .thenAnswer((_) async {});

        await repository.signUp(
          email: 'new@test.com',
          password: 'Strong1234',
          displayName: 'Fallback',
        );

        verify(() => mockRemote.syncUserProfile(mockUser)).called(1);
      });

      test('throws AuthException on signup failure', () async {
        when(() => mockAuth.signUp(
              email: 'dup@test.com',
              password: 'Strong1234',
              data: {'display_name': 'Dup'},
            )).thenThrow(
          const supa.AuthException('User already registered'),
        );

        expect(
          () => repository.signUp(
            email: 'dup@test.com',
            password: 'Strong1234',
            displayName: 'Dup',
          ),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            'User already registered',
          )),
        );
      });
    });

    group('signOut', () {
      test('completes without error', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        await expectLater(repository.signOut(), completes);
        verify(() => mockAuth.signOut()).called(1);
      });

      test('throws AuthException on signOut failure', () async {
        when(() => mockAuth.signOut()).thenThrow(
          const supa.AuthException('Session expired'),
        );

        expect(
          () => repository.signOut(),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('resetPassword', () {
      test('sends reset email', () async {
        when(() => mockAuth.resetPasswordForEmail('user@test.com'))
            .thenAnswer((_) async {});

        await expectLater(
          repository.resetPassword('user@test.com'),
          completes,
        );
      });

      test('throws AuthException on failure', () async {
        when(() => mockAuth.resetPasswordForEmail('bad@test.com')).thenThrow(
          const supa.AuthException('Rate limited'),
        );

        expect(
          () => repository.resetPassword('bad@test.com'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('currentUser', () {
      test('returns user when session exists', () {
        final mockUser = MockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        expect(repository.currentUser, isNotNull);
      });

      test('returns null when no session', () {
        when(() => mockAuth.currentUser).thenReturn(null);

        expect(repository.currentUser, isNull);
      });
    });
  });
}
