import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:luxlog/features/notifications/data/repositories/notification_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  late MockSupabaseClient mockClient;
  late NotificationRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = NotificationRepository(mockClient);
  });

  group('NotificationRepository — provider integration', () {
    group('fetchNotifications returns correct shape', () {
      test('maps actor and photo joins', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final notifications = [
          {
            'id': 'n-1',
            'type': 'like',
            'recipient_id': 'user-1',
            'actor_id': 'user-2',
            'read_at': null,
            'created_at': '2026-04-20T10:00:00Z',
            'actor': {'username': 'alice', 'avatar_url': 'https://a.com/a.jpg'},
            'photo': {'id': 'p-1', 'image_url': 'https://a.com/p.jpg'},
          },
          {
            'id': 'n-2',
            'type': 'follow',
            'recipient_id': 'user-1',
            'actor_id': 'user-3',
            'read_at': '2026-04-19T08:00:00Z',
            'created_at': '2026-04-19T08:00:00Z',
            'actor': {'username': 'bob', 'avatar_url': null},
            'photo': null,
          },
        ];

        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any()))
            .thenReturn(_FakePostgrestFilterBuilder(notifications));

        final result = await repository.fetchNotifications('user-1');
        expect(result.length, 2);
        expect(result[0]['type'], 'like');
        expect(result[0]['actor']['username'], 'alice');
        expect(result[1]['type'], 'follow');
        expect(result[1]['photo'], isNull);
      });

      test('returns empty when no notifications', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any()))
            .thenReturn(_FakePostgrestFilterBuilder([]));

        final result = await repository.fetchNotifications('user-1');
        expect(result, isEmpty);
      });
    });

    group('unreadCount for badge', () {
      test('counts only unread items', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id'))
            .thenReturn(_FakePostgrestFilterBuilder([
          {'id': '1'},
          {'id': '2'},
          {'id': '3'},
          {'id': '4'},
          {'id': '5'},
        ]));

        final count = await repository.unreadCount('user-1');
        expect(count, 5);
      });

      test('returns 0 for fully read inbox', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id'))
            .thenReturn(_FakePostgrestFilterBuilder([]));

        final count = await repository.unreadCount('user-1');
        expect(count, 0);
      });
    });

    group('markAllAsRead clears badge', () {
      test('completes without error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.update(any()))
            .thenReturn(_FakePostgrestFilterBuilder([]));

        await expectLater(
          repository.markAllAsRead('user-1'),
          completes,
        );
      });

      test('throws NetworkException on DB failure', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.update(any())).thenThrow(
          PostgrestException(message: 'timeout', code: '408'),
        );

        expect(
          () => repository.markAllAsRead('user-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('error handling', () {
      test('fetchNotifications wraps PostgrestException', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenThrow(
          PostgrestException(message: 'forbidden', code: '403'),
        );

        expect(
          () => repository.fetchNotifications('user-1'),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('403'),
            ),
          ),
        );
      });

      test('fetchNotifications wraps generic exceptions', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any()))
            .thenThrow(Exception('socket error'));

        expect(
          () => repository.fetchNotifications('user-1'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('unreadCount wraps generic exceptions', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications'))
            .thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id'))
            .thenThrow(Exception('network down'));

        expect(
          () => repository.unreadCount('user-1'),
          throwsA(isA<NetworkException>()),
        );
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
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(
          String column, Object? value) =>
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
