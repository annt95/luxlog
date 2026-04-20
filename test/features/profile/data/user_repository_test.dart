import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:luxlog/features/profile/data/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

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

  group('UserRepository', () {
    group('currentUser', () {
      test('returns null when not authenticated', () {
        when(() => mockAuthClient.currentUser).thenReturn(null);
        expect(repository.currentUser, isNull);
      });

      test('returns user when authenticated', () {
        final mockUser = MockUser();
        when(() => mockAuthClient.currentUser).thenReturn(mockUser);
        expect(repository.currentUser, mockUser);
      });
    });

    group('fetchProfile', () {
      test('returns profile data on success', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final profileData = {
          'id': 'user-1',
          'username': 'johndoe',
          'full_name': 'John Doe',
          'bio': 'Photographer',
          'avatar_url': 'https://example.com/avatar.jpg',
          'followers': [
            {'count': 42}
          ],
          'following': [
            {'count': 15}
          ],
        };

        when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakeFilterForSingle(profileData),
        );

        final result = await repository.fetchProfile('johndoe');
        expect(result['username'], 'johndoe');
        expect(result['full_name'], 'John Doe');
      });

      test('throws NetworkException when user not found', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenThrow(
          const PostgrestException(message: 'not found', code: 'PGRST116'),
        );

        expect(
          () => repository.fetchProfile('nonexistent'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('fetchCurrentProfile', () {
      test('throws AuthException when not logged in', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.fetchCurrentProfile(),
          throwsA(isA<AuthException>()),
        );
      });

      test('returns current user profile on success', () async {
        final mockUser = MockUser();
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockAuthClient.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakeFilterForSingle({
            'id': 'user-1',
            'username': 'me',
            'full_name': 'Me',
          }),
        );

        final result = await repository.fetchCurrentProfile();
        expect(result['id'], 'user-1');
      });
    });

    group('updateProfile', () {
      test('throws AuthException when not logged in', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.updateProfile(fullName: 'New Name'),
          throwsA(isA<AuthException>()),
        );
      });

      test('updates profile for authenticated user', () async {
        final mockUser = MockUser();
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockAuthClient.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.update(any())).thenReturn(
          _FakeFilterList(<Map<String, dynamic>>[]),
        );

        await expectLater(
          repository.updateProfile(fullName: 'New Name', bio: 'Updated'),
          completes,
        );
      });
    });

    group('followUser', () {
      test('throws AuthException when not logged in', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.followUser('target-id'),
          throwsA(isA<AuthException>()),
        );
      });

      test('inserts follow relationship', () async {
        final mockUser = MockUser();
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockAuthClient.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockSupabaseClient.from('follows')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.insert(any())).thenReturn(
          _FakeFilterList(<Map<String, dynamic>>[]),
        );

        await expectLater(repository.followUser('target-id'), completes);
      });
    });

    group('unfollowUser', () {
      test('throws AuthException when not logged in', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.unfollowUser('target-id'),
          throwsA(isA<AuthException>()),
        );
      });

      test('deletes follow relationship', () async {
        final mockUser = MockUser();
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockAuthClient.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockSupabaseClient.from('follows')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.delete()).thenReturn(
          _FakeFilterList(<Map<String, dynamic>>[]),
        );

        await expectLater(repository.unfollowUser('target-id'), completes);
      });
    });

    group('fetchFollowers', () {
      test('returns list of followers', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final followers = [
          {
            'profiles': {'username': 'follower1', 'avatar_url': null}
          },
        ];
        when(() => mockSupabaseClient.from('follows')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakeFilterList(followers),
        );

        final result = await repository.fetchFollowers('user-1');
        expect(result.length, 1);
      });

      test('throws NetworkException on error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockSupabaseClient.from('follows')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenThrow(
          const PostgrestException(message: 'error', code: '500'),
        );

        expect(
          () => repository.fetchFollowers('user-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('resolveUserIdByUsername', () {
      test('returns user ID for valid username', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenReturn(
          _FakeFilterForSingle({'id': 'resolved-user-id'}),
        );

        final result = await repository.resolveUserIdByUsername('johndoe');
        expect(result, 'resolved-user-id');
      });

      test('throws NetworkException when username not found', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenThrow(
          const PostgrestException(message: 'not found', code: 'PGRST116'),
        );

        expect(
          () => repository.resolveUserIdByUsername('ghost'),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}

class _FakeFilterForSingle extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final Map<String, dynamic>? _single;
  _FakeFilterForSingle(this._single);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) => this;

  @override
  PostgrestBuilder<Map<String, dynamic>> single() {
    if (_single == null) {
      throw const PostgrestException(message: 'not found', code: 'PGRST116');
    }
    return _FakeSingleBuilder(_single!);
  }
}

class _FakeFilterList extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  _FakeFilterList(this._data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(Map<String, Object> query) => this;

  @override
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

class _FakeSingleBuilder extends Fake
    implements PostgrestBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  _FakeSingleBuilder(this._data);

  @override
  Future<Map<String, dynamic>> then<R>(
      FutureOr<R> Function(Map<String, dynamic>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

