import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luxlog/features/tags/data/repositories/tag_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late TagRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = TagRepository(mockClient);
  });

  group('TagRepository — provider layer', () {
    group('searchTags', () {
      test('returns matching tags', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final tags = [
          {'id': 1, 'name': 'portra400', 'usage_count': 42},
          {'id': 2, 'name': 'portra160', 'usage_count': 18},
        ];

        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenReturn(
          _FakePostgrestFilterBuilder(tags),
        );

        final result = await repository.searchTags('portra');
        expect(result.length, 2);
        expect(result.first['name'], 'portra400');
      });

      test('returns empty list for empty query', () async {
        final result = await repository.searchTags('');
        expect(result, isEmpty);
      });

      test('returns empty list for whitespace query', () async {
        final result = await repository.searchTags('   ');
        expect(result, isEmpty);
      });

      test('throws NetworkException on DB error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenThrow(
          PostgrestException(message: 'error', code: '500'),
        );

        expect(
          () => repository.searchTags('test'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getTrendingTags', () {
      test('returns tags sorted by usage_count', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final tags = [
          {'id': 1, 'name': 'film', 'usage_count': 120},
          {'id': 2, 'name': '35mm', 'usage_count': 95},
          {'id': 3, 'name': 'analog', 'usage_count': 80},
        ];

        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenReturn(
          _FakePostgrestFilterBuilder(tags),
        );

        final result = await repository.getTrendingTags();
        expect(result.length, 3);
        expect(result.first['usage_count'], 120);
      });

      test('returns empty when no trending tags', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenReturn(
          _FakePostgrestFilterBuilder([]),
        );

        final result = await repository.getTrendingTags();
        expect(result, isEmpty);
      });

      test('respects custom limit', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenReturn(
          _FakePostgrestFilterBuilder([
            {'id': 1, 'name': 'film', 'usage_count': 50},
          ]),
        );

        final result = await repository.getTrendingTags(limit: 5);
        expect(result, isNotEmpty);
      });

      test('throws NetworkException on error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select()).thenThrow(
          PostgrestException(message: 'timeout', code: '408'),
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
            'tag': {'id': 1, 'name': 'portra400'}
          },
        ];

        when(() => mockClient.from('photo_tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakePostgrestFilterBuilder(photoTags),
        );

        final result = await repository.getTagsByPhoto('photo-1');
        expect(result, isNotEmpty);
      });

      test('returns empty when no tags', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('photo_tags')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakePostgrestFilterBuilder([]),
        );

        final result = await repository.getTagsByPhoto('photo-1');
        expect(result, isEmpty);
      });
    });
  });
}

class _FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  _FakePostgrestFilterBuilder(this._data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> ilike(
          String column, Object value) =>
      this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> gt(
          String column, Object value) =>
      this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false,
          String? referencedTable,
          bool nullsFirst = false}) =>
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
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}
