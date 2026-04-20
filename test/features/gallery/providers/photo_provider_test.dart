import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:luxlog/features/gallery/data/repositories/photo_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late PhotoRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockClient.auth).thenReturn(mockAuth);
    repository = PhotoRepository(mockClient);
  });

  group('PhotoRepository — fetchFeed (provider layer)', () {
    test('returns data with pagination params', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final photos = [
        {
          'id': 'p-1',
          'title': 'Photo 1',
          'image_url': 'https://example.com/1.jpg',
          'created_at': '2026-04-20T10:00:00Z',
        },
        {
          'id': 'p-2',
          'title': 'Photo 2',
          'image_url': 'https://example.com/2.jpg',
          'created_at': '2026-04-20T09:00:00Z',
        },
      ];

      when(() => mockClient.from('photos')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(
        _FakePostgrestFilterBuilder(photos),
      );

      final result = await repository.fetchFeed(page: 0, limit: 20);
      expect(result.length, 2);
      expect(result.first['id'], 'p-1');
    });

    test('page 1 with limit 10 still works', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      when(() => mockClient.from('photos')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(
        _FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
      );

      final result = await repository.fetchFeed(page: 1, limit: 10);
      expect(result, isEmpty);
    });

    test('throws NetworkException on DB error', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      when(() => mockClient.from('photos')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenThrow(
        PostgrestException(message: 'timeout', code: '408'),
      );

      expect(
        () => repository.fetchFeed(page: 0, limit: 20),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('PhotoRepository — fetchPhotoById (detail provider)', () {
    test('returns single photo with nested data', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final photo = {
        'id': 'p-1',
        'title': 'Sunset',
        'image_url': 'https://example.com/sunset.jpg',
        'profiles': {'username': 'john', 'full_name': 'John'},
        'comments': <Map<String, dynamic>>[],
      };

      when(() => mockClient.from('photos')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(
        _FakePostgrestFilterBuilder([photo], singleMode: true),
      );

      final result = await repository.fetchPhotoById('p-1');
      expect(result['title'], 'Sunset');
      expect(result['profiles'], isNotNull);
    });

    test('throws NetworkException when photo not found', () async {
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      when(() => mockClient.from('photos')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenThrow(
        PostgrestException(message: 'not found', code: 'PGRST116'),
      );

      expect(
        () => repository.fetchPhotoById('nonexistent'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('PhotoRepository — uploadPhoto', () {
    test('throws AuthException when not authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.uploadPhoto(
          fileBytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'test.jpg',
          title: 'Test',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('AuthException message is correct', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.uploadPhoto(
          fileBytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'test.jpg',
          title: 'Test',
        ),
        throwsA(
          predicate<AuthException>(
            (e) => e.message == 'Vui lòng đăng nhập để tải ảnh',
          ),
        ),
      );
    });
  });

  group('PhotoRepository — deletePhoto', () {
    test('throws AuthException when not logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => repository.deletePhoto('photo-1'),
        throwsA(isA<AuthException>()),
      );
    });
  });
}

/// Fake PostgREST filter builder that intercepts chained calls
class _FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  final bool singleMode;
  _FakePostgrestFilterBuilder(this._data, {this.singleMode = false});

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> match(
          Map<String, Object> query) =>
      this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false,
          String? referencedTable,
          bool nullsFirst = false}) =>
      _FakePostgrestTransformBuilder(_data);

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      _FakePostgrestTransformBuilder(_data);

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() =>
      _FakeSingleTransformBuilder(_data.isNotEmpty ? _data.first : {});

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
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

class _FakeSingleTransformBuilder extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  _FakeSingleTransformBuilder(this._data);

  @override
  Future<Map<String, dynamic>> then<R>(
      FutureOr<R> Function(Map<String, dynamic>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}
