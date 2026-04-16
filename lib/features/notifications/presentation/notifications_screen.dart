import 'package:flutter/material.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/app/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Activity', style: AppTextStyles.headline),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 15,
        itemBuilder: (context, index) {
          final isLike = index % 3 == 0;
          final isFollow = index % 3 == 1;
          final isComment = index % 3 == 2;
          
          return _NotificationTile(
             isLike: isLike,
             isFollow: isFollow,
             isComment: isComment,
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final bool isLike;
  final bool isFollow;
  final bool isComment;

  const _NotificationTile({
    required this.isLike,
    required this.isFollow,
    required this.isComment,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    String actionText;
    
    if (isLike) {
      icon = Icons.favorite;
      iconColor = Colors.redAccent;
      actionText = 'liked your photo';
    } else if (isFollow) {
      icon = Icons.person_add;
      iconColor = AppColors.primary;
      actionText = 'started following you';
    } else {
      icon = Icons.mode_comment;
      iconColor = Colors.white70;
      actionText = 'commented: "Incredible tones here!"';
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
              backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyText,
                      children: [
                        TextSpan(
                          text: 'sarah_lens ',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        TextSpan(text: actionText),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('2 hours ago', style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                ],
              ),
            ),
            if (!isFollow) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Image.network(
                  'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&q=80&w=100',
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (isFollow) ...[
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: BorderSide(color: AppColors.outline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                ),
                child: Text('Follow', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ]
        ),
      ),
    );
  }
}
