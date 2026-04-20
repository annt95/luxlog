import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:luxlog/features/gallery/data/repositories/photo_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageBucket extends Mock implements StorageFileApi {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuthClient;
  late PhotoRepository repository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockAuthClient);
    repository = PhotoRepository(mockSupabaseClient);
  });

  group('PhotoRepository', () {
    group('uploadPhoto', () {
      test('throws AuthException when user is not logged in', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.uploadPhoto(
            fileBytes: Uint8List.fromList([1, 2, 3]),
            fileName: 'test.jpg',
            title: 'My photo',
          ),
          throwsA(isA<AuthException>()),
        );
      });

      test('throws AuthException with correct error message', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.uploadPhoto(
            fileBytes: Uint8List.fromList([1, 2, 3]),
            fileName: 'test.jpg',
            title: 'My photo',
          ),
          throwsA(predicate<AuthException>(
            (e) => e.message == 'Vui lòng đăng nhập để tải ảnh',
          )),
        );
      });
    });

    group('fetchFeed', () {
      test('returns list of photos on success', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final photos = [
          {
            'id': 'p-1',
            'title': 'Sunset',
            'image_url': 'https://storage.example.com/photo.jpg',
            'created_at': '2026-04-20T10:00:00Z',
            'profiles': {'username': 'john', 'avatar_url': null, 'full_name': 'John Doe'},
          }
        ];

        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakePostgrestFilterBuilder(photos),
        );

        final result = await repository.fetchFeed(page: 0, limit: 20);
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, 1);
        expect(result.first['title'], 'Sunset');
      });

      test('returns empty list when no photos', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
        );

        final result = await repository.fetchFeed(page: 0, limit: 20);
        expect(result, isEmpty);
      });

      test('throws NetworkException on PostgrestException', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenThrow(
          PostgrestException(message: 'connection timeout', code: '408'),
        );

        expect(
          () => repository.fetchFeed(page: 0, limit: 20),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('fetchByUser', () {
      test('returns photos filtered by user', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final photos = [
          {'id': 'p-1', 'user_id': 'user-1', 'title': 'My photo'}
        ];

        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakePostgrestFilterBuilder(photos),
        );

        final result = await repository.fetchByUser(userId: 'user-1', page: 0);
        expect(result.length, 1);
        expect(result.first['user_id'], 'user-1');
      });

      test('throws NetworkException on error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenThrow(
          PostgrestException(message: 'error', code: '500'),
        );

        expect(
          () => repository.fetchByUser(userId: 'user-1', page: 0),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('countByUser', () {
      test('returns correct photo count', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final rows = [
          {'id': '1'},
          {'id': '2'},
          {'id': '3'},
        ];

        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenReturn(
          _FakePostgrestFilterBuilder(rows),
        );

        final result = await repository.countByUser('user-1');
        expect(result, 3);
      });

      test('returns 0 when user has no photos', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenReturn(
          _FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
        );

        final result = await repository.countByUser('user-1');
        expect(result, 0);
      });
    });

    group('totalViewsByUser', () {
      test('sums views_count across all photos', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final rows = [
          {'views_count': 10},
          {'views_count': 25},
          {'views_count': 5},
        ];

        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('views_count')).thenReturn(
          _FakePostgrestFilterBuilder(rows),
        );

        final result = await repository.totalViewsByUser('user-1');
        expect(result, 40);
      });

      test('handles null views_count gracefully', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final rows = [
          {'views_count': 10},
          {'views_count': null},
          {'views_count': 5},
        ];

        when(() => mockSupabaseClient.from('photos')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('views_count')).thenReturn(
          _FakePostgrestFilterBuilder(rows),
        );

        final result = await repository.totalViewsByUser('user-1');
        expect(result, 15);
      });
    });

    group('likePhoto', () {
      test('throws AuthException when not logged in', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.likePhoto('photo-1'),
          throwsA(isA<AuthException>()),
        );
      });

      test('inserts like for authenticated user', () async {
        final mockUser = MockUser();
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockAuthClient.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockSupabaseClient.from('likes')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.insert(any())).thenReturn(
          _FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
        );

        await expectLater(repository.likePhoto('photo-1'), completes);
      });
    });

    group('unlikePhoto', () {
      test('throws AuthException when not logged in', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.unlikePhoto('photo-1'),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('addComment', () {
      test('throws AuthException when not logged in', () async {
        when(() => mockAuthClient.currentUser).thenReturn(null);

        expect(
          () => repository.addComment('photo-1', 'Nice shot!'),
          throwsA(isA<AuthException>()),
        );
      });

      test('inserts comment for authenticated user', () async {
        final mockUser = MockUser();
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockAuthClient.currentUser).thenReturn(mockUser);
        when(() => mockUser.id).thenReturn('user-1');
        when(() => mockSupabaseClient.from('comments')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.insert(any())).thenReturn(
          _FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
        );

        await expectLater(
          repository.addComment('photo-1', 'Great composition!'),
          completes,
        );
      });
    });
  });
}

/// Fake for Supabase PostgREST filter builder chain
class _FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  _FakePostgrestFilterBuilder(this._data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(Map<String, Object> query) => this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false, String? referencedTable, bool nullsFirst = false}) =>
      _FakePostgrestTransformBuilder(_data);

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      _FakePostgrestTransformBuilder(_data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(String column, Object? value) => this;

  @override
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

class _FakePostgrestTransformBuilder extends Fake
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  _FakePostgrestTransformBuilder(this._data);

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> range(int from, int to) =>
      _FakePostgrestFilterBuilder(_data);

  @override
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

