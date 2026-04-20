import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';
import 'package:luxlog/features/notifications/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Activity', style: AppTextStyles.headline),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: const Center(
          child: Text('Please sign in to view notifications'),
        ),
      );
    }

    final notificationsAsync = ref.watch(notificationsProvider(user.id));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Activity', style: AppTextStyles.headline),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () async {
              await markAllNotificationsAsRead(ref, user.id);
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => const Center(
          child: Text('Failed to load notifications'),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No activity yet'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _NotificationTile(notification: items[index]);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationTile({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String actionText;
    final type = notification['type'] as String? ?? 'like';
    final actor = notification['actor'] as Map<String, dynamic>?;
    final photo = notification['photo'] as Map<String, dynamic>?;
    final actorName = actor?['username'] as String? ?? 'Someone';
    final avatarUrl = actor?['avatar_url'] as String?;
    final photoUrl = photo?['image_url'] as String?;
    final createdAt = DateTime.tryParse(
      notification['created_at'] as String? ?? '',
    );
    final hasUnread = notification['read_at'] == null;

    if (type == 'like') {
      icon = Icons.favorite;
      actionText = 'liked your photo';
    } else if (type == 'follow') {
      icon = Icons.person_add;
      actionText = 'started following you';
    } else if (type == 'comment') {
      icon = Icons.mode_comment;
      actionText = 'commented on your photo';
    } else {
      icon = Icons.local_offer_outlined;
      actionText = 'tagged your photo';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.surfaceContainerHigh,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      actorName.isNotEmpty ? actorName[0].toUpperCase() : 'U',
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body,
                      children: [
                        TextSpan(
                          text: '$actorName ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextSpan(text: actionText),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_relativeTime(createdAt), style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                ],
              ),
            ),
            Icon(icon, color: hasUnread ? AppColors.primary : AppColors.onSurfaceVariant),
            if (photoUrl != null) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Image.network(
                  photoUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ]
        ),
      ),
    );
  }
}

String _relativeTime(DateTime? dateTime) {
  if (dateTime == null) return 'Just now';
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
