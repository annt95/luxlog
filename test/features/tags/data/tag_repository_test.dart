import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:luxlog/features/tags/data/repositories/tag_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late TagRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = TagRepository(mockClient);
  });

  group('TagRepository', () {
    group('parseHashtags (static)', () {
      test('extracts hashtags from caption text', () {
        final hashtags = TagRepository.parseHashtags(
          'Golden hour #street #film #35mm',
        );
        expect(hashtags, ['street', 'film', '35mm']);
      });

      test('returns empty list when no hashtags', () {
        final hashtags = TagRepository.parseHashtags('No tags here');
        expect(hashtags, isEmpty);
      });

      test('handles text starting with hashtag', () {
        final hashtags = TagRepository.parseHashtags('#portra400 test');
        expect(hashtags, ['portra400']);
      });

      test('handles multiple consecutive hashtags', () {
        final hashtags = TagRepository.parseHashtags('#film #analog #kodak');
        expect(hashtags, ['film', 'analog', 'kodak']);
      });
    });

    group('searchTags', () {
      test('returns empty list for empty query', () async {
        final result = await repository.searchTags('');
        expect(result, isEmpty);
      });

      test('returns empty list for whitespace-only query', () async {
        final result = await repository.searchTags('   ');
        expect(result, isEmpty);
      });

      test('returns matching tags on success', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final tags = [
          {'id': '1', 'name': 'streetphotography', 'usage_count': 42},
          {'id': '2', 'name': 'street', 'usage_count': 30},
        ];

        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenReturn(
          _FakeFilterBuilder(tags),
        );

        final result = await repository.searchTags('street');
        expect(result.length, 2);
        expect(result.first['name'], 'streetphotography');
      });

      test('throws NetworkException on error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenThrow(
          const PostgrestException(message: 'error', code: '500'),
        );

        expect(
          () => repository.searchTags('test'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getTrendingTags', () {
      test('returns trending tags sorted by usage', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final tags = [
          {'id': '1', 'name': 'film', 'usage_count': 100},
          {'id': '2', 'name': 'portra400', 'usage_count': 85},
          {'id': '3', 'name': 'analog', 'usage_count': 70},
        ];

        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenReturn(
          _FakeFilterBuilder(tags),
        );

        final result = await repository.getTrendingTags(limit: 20);
        expect(result.length, 3);
        expect(result.first['name'], 'film');
      });

      test('returns empty on error-free but no results', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenReturn(
          _FakeFilterBuilder(<Map<String, dynamic>>[]),
        );

        final result = await repository.getTrendingTags();
        expect(result, isEmpty);
      });

      test('throws NetworkException on failure', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenThrow(
          const PostgrestException(message: 'timeout', code: '408'),
        );

        expect(
          () => repository.getTrendingTags(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getTagsByPhoto', () {
      test('returns tags for a photo', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final photoTags = [
          {
            'tags': {'id': '1', 'name': 'film', 'usage_count': 50}
          },
          {
            'tags': {'id': '2', 'name': 'analog', 'usage_count': 30}
          },
        ];

        when(() => mockClient.from('photo_tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakeFilterBuilder(photoTags),
        );

        final result = await repository.getTagsByPhoto('photo-1');
        expect(result.length, 2);
        expect(result.first['name'], 'film');
      });

      test('throws NetworkException on error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('photo_tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenThrow(
          const PostgrestException(message: 'error', code: '500'),
        );

        expect(
          () => repository.getTagsByPhoto('photo-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getPhotosByTag', () {
      test('returns empty list when tag not found', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenReturn(
          _FakeFilterForMaybe(null),
        );

        final result = await repository.getPhotosByTag('nonexistent', page: 0);
        expect(result, isEmpty);
      });

      test('throws NetworkException on error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenThrow(
          const PostgrestException(message: 'error', code: '500'),
        );

        expect(
          () => repository.getPhotosByTag('film', page: 0),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}

class _FakeFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  _FakeFilterBuilder(this._data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gt(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> ilike(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false, String? referencedTable, bool nullsFirst = false}) =>
      _FakeTransformBuilder(_data);

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      _FakeTransformBuilder(_data);

  @override
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

class _FakeTransformBuilder extends Fake
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  _FakeTransformBuilder(this._data);

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> range(int from, int to) =>
      _FakeFilterBuilder(_data);

  @override
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

class _FakeFilterForMaybe extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final Map<String, dynamic>? _single;
  _FakeFilterForMaybe(this._single);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) => this;

  @override
  PostgrestBuilder<Map<String, dynamic>?> maybeSingle() =>
      _FakeMaybeSingleBuilder(_single);
}

class _FakeMaybeSingleBuilder extends Fake
    implements PostgrestBuilder<Map<String, dynamic>?> {
  final Map<String, dynamic>? _data;
  _FakeMaybeSingleBuilder(this._data);

  @override
  Future<Map<String, dynamic>?> then<R>(
      FutureOr<R> Function(Map<String, dynamic>?) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

