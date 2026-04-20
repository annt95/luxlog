import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:luxlog/features/notifications/data/repositories/notification_repository.dart';
import 'package:luxlog/core/errors/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestBuilder extends Mock implements PostgrestFilterBuilder {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

// Helper to mock the Supabase query chain
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

void main() {
  late MockSupabaseClient mockClient;
  late NotificationRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = NotificationRepository(mockClient);
  });

  group('NotificationRepository', () {
    group('fetchNotifications', () {
      test('returns list of notifications on success', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final notifications = [
          {
            'id': '1',
            'type': 'like',
            'recipient_id': 'user-1',
            'actor_id': 'user-2',
            'read_at': null,
            'created_at': '2026-04-20T10:00:00Z',
            'actor': {'username': 'john', 'avatar_url': null},
            'photo': {'id': 'p-1', 'image_url': 'https://example.com/img.jpg'},
          }
        ];

        when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenReturn(
          _FakePostgrestFilterBuilder(notifications),
        );

        final result = await repository.fetchNotifications('user-1');
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, 1);
        expect(result.first['type'], 'like');
      });

      test('throws NetworkException on PostgrestException', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select(any())).thenThrow(
          PostgrestException(message: 'DB error', code: '500'),
        );

        expect(
          () => repository.fetchNotifications('user-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('unreadCount', () {
      test('returns count of unread notifications', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final unreadItems = [
          {'id': '1'},
          {'id': '2'},
          {'id': '3'},
        ];

        when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenReturn(
          _FakePostgrestFilterBuilder(unreadItems),
        );

        final result = await repository.unreadCount('user-1');
        expect(result, 3);
      });

      test('returns 0 when no unread notifications', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenReturn(
          _FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
        );

        final result = await repository.unreadCount('user-1');
        expect(result, 0);
      });

      test('throws NetworkException on error', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.select('id')).thenThrow(
          PostgrestException(message: 'timeout', code: '408'),
        );

        expect(
          () => repository.unreadCount('user-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('markAllAsRead', () {
      test('calls update on notifications table', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.update(any())).thenReturn(
          _FakePostgrestFilterBuilder(<Map<String, dynamic>>[]),
        );

        // Should not throw
        await expectLater(
          repository.markAllAsRead('user-1'),
          completes,
        );
      });

      test('throws NetworkException on failure', () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('notifications')).thenReturn(mockQueryBuilder);
        when(() => mockQueryBuilder.update(any())).thenThrow(
          PostgrestException(message: 'permission denied', code: '403'),
        );

        expect(
          () => repository.markAllAsRead('user-1'),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}

/// A fake that intercepts chained Supabase filter calls and returns preset data.
/// This avoids complex mock chains for .eq().isFilter().order().limit() etc.
class _FakePostgrestFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final List<Map<String, dynamic>> _data;
  _FakePostgrestFilterBuilder(this._data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> isFilter(String column, Object? value) => this;

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column,
          {bool ascending = false, String? referencedTable, bool nullsFirst = false}) =>
      _FakePostgrestTransformBuilder(_data);

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> limit(int count,
          {String? referencedTable}) =>
      _FakePostgrestTransformBuilder(_data);

  // For update chain
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
