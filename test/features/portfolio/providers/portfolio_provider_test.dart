import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luxlog/features/portfolio/data/repositories/portfolio_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late PortfolioRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = PortfolioRepository(mockClient);
  });

  group('PortfolioRepository — provider layer', () {
    group('fetchPortfolio', () {
      test('returns blocks from JSON string', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenReturn(
          _FakePostgrestFilterBuilder(
            [
              {
                'blocks':
                    '[{"type":"header","content":"Welcome"},{"type":"photo","id":"p-1"}]'
              }
            ],
            maybeSingleMode: true,
            singleResult: {
              'blocks':
                  '[{"type":"header","content":"Welcome"},{"type":"photo","id":"p-1"}]'
            },
          ),
        );

        final result = await repository.fetchPortfolio('user-1');
        expect(result.length, 2);
        expect(result.first['type'], 'header');
      });

      test('returns blocks from List type', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final blocksList = [
          {'type': 'header', 'content': 'My Portfolio'},
        ];
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenReturn(
          _FakePostgrestFilterBuilder(
            [
              {'blocks': blocksList}
            ],
            maybeSingleMode: true,
            singleResult: {'blocks': blocksList},
          ),
        );

        final result = await repository.fetchPortfolio('user-1');
        expect(result.length, 1);
        expect(result.first['type'], 'header');
      });

      test('returns empty list when no portfolio exists', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenReturn(
          _FakePostgrestFilterBuilder(
            [],
            maybeSingleMode: true,
            singleResult: null,
          ),
        );

        final result = await repository.fetchPortfolio('user-1');
        expect(result, isEmpty);
      });

      test('returns empty list on PGRST116 (not found)', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenThrow(
          PostgrestException(message: 'not found', code: 'PGRST116'),
        );

        final result = await repository.fetchPortfolio('user-1');
        expect(result, isEmpty);
      });

      test('throws NetworkException on database error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('blocks')).thenThrow(
          PostgrestException(message: 'server error', code: '500'),
        );

        expect(
          () => repository.fetchPortfolio('user-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('savePortfolio', () {
      test('upserts blocks as JSON string', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(any())).thenReturn(
          _FakePostgrestFilterBuilder([]),
        );

        await expectLater(
          repository.savePortfolio('user-1', [
            {'type': 'header', 'content': 'Hello'},
          ]),
          completes,
        );
      });

      test('throws NetworkException on failure', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('portfolios')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.upsert(any())).thenThrow(
          PostgrestException(message: 'permission denied', code: '403'),
        );

        expect(
          () => repository.savePortfolio('user-1', []),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('fetchPublicPortfolio', () {
      test('throws NetworkException when user not found', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('profiles')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenThrow(
          PostgrestException(message: 'not found', code: 'PGRST116'),
        );

        expect(
          () => repository.fetchPublicPortfolio('nonexistent-slug'),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}

class _FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  final bool maybeSingleMode;
  final Map<String, dynamic>? singleResult;
  _FakePostgrestFilterBuilder(
    this._data, {
    this.maybeSingleMode = false,
    this.singleResult,
  });

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(
          String column, Object value) =>
      this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() =>
      _FakeMaybeSingleBuilder(singleResult);

  @override
  PostgrestTransformBuilder<Map<String, dynamic>> single() =>
      _FakeSingleBuilder(singleResult ?? {});

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false,
          String? referencedTable,
          bool nullsFirst = false}) =>
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
  Future<List<Map<String, dynamic>>> then<R>(
      FutureOr<R> Function(List<Map<String, dynamic>>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

class _FakeMaybeSingleBuilder extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  final Map<String, dynamic>? _data;
  _FakeMaybeSingleBuilder(this._data);

  @override
  Future<Map<String, dynamic>?> then<R>(
      FutureOr<R> Function(Map<String, dynamic>?) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}

class _FakeSingleBuilder extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  _FakeSingleBuilder(this._data);

  @override
  Future<Map<String, dynamic>> then<R>(
      FutureOr<R> Function(Map<String, dynamic>) onValue,
      {Function? onError}) {
    return Future.value(_data).then(onValue).then((v) => _data);
  }
}
