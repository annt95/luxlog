import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(SupabaseService.client);
});

final notificationsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamNotifications(userId);
});

final unreadNotificationCountProvider = FutureProvider.family<int, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.unreadCount(userId);
});

/// Marks all notifications as read for [userId] and refreshes the unread badge.
Future<void> markAllNotificationsAsRead(WidgetRef ref, String userId) async {
  final repository = ref.read(notificationRepositoryProvider);
  await repository.markAllAsRead(userId);
  ref.invalidate(unreadNotificationCountProvider);
}
