import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:luxlog/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late PortfolioRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = PortfolioRepository(mockClient);
  });

  group('PortfolioRepository', () {
    group('fetchPortfolio', () {
      test('returns empty list when no portfolio exists (null response)', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenReturn(
          _FakeFilterForMaybe(null),
        );

        final result = await repository.fetchPortfolio('user-1');
        expect(result, isEmpty);
      });

      test('parses blocks from JSON string', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final blocks = [
          {'type': 'header', 'content': 'My Work'},
          {'type': 'photo', 'photoId': 'p-1'},
        ];
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenReturn(
          _FakeFilterForMaybe({'blocks': jsonEncode(blocks)}),
        );

        final result = await repository.fetchPortfolio('user-1');
        expect(result.length, 2);
        expect(result.first['type'], 'header');
      });

      test('parses blocks from List format', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenReturn(
          _FakeFilterForMaybe({
            'blocks': [
              {'type': 'text', 'value': 'Hello'}
            ]
          }),
        );

        final result = await repository.fetchPortfolio('user-1');
        expect(result.length, 1);
        expect(result.first['type'], 'text');
      });

      test('returns empty on PGRST116 (not found)', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenThrow(
          const PostgrestException(message: 'No rows found', code: 'PGRST116'),
        );

        final result = await repository.fetchPortfolio('user-1');
        expect(result, isEmpty);
      });

      test('throws NetworkException on other errors', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenThrow(
          const PostgrestException(message: 'timeout', code: '500'),
        );

        expect(
          () => repository.fetchPortfolio('user-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('savePortfolio', () {
      test('upserts portfolio with JSON-encoded blocks', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(any())).thenReturn(
          _FakeFilterList(<Map<String, dynamic>>[]),
        );

        await expectLater(
          repository.savePortfolio('user-1', [
            {'type': 'header', 'content': 'Portfolio'}
          ]),
          completes,
        );
      });

      test('throws NetworkException on upsert failure', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(any())).thenThrow(
          const PostgrestException(message: 'permission denied', code: '403'),
        );

        expect(
          () => repository.savePortfolio('user-1', []),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('fetchPublicPortfolio', () {
      test('throws NetworkException when slug user not found', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenReturn(
          _FakeFilterForSingle(null),
        );

        expect(
          () => repository.fetchPublicPortfolio('nonexistent'),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
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

class _FakeFilterList extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  _FakeFilterList(this._data);

  @override
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

