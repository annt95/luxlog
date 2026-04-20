import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/core/services/image_url_optimizer.dart';
import 'package:luxlog/features/gallery/presentation/widgets/comment_bottom_sheet.dart';
import 'package:luxlog/shared/widgets/skeleton_widgets.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';

/// Module 2: Social Feed — Instagram-like following feed
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();

  int _selectedTab = 0; // 0: For You, 1: Following

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(
      photoFeedProvider(
        page: 0,
        limit: 24,
        tab: _selectedTab == 0 ? 'for-you' : 'following',
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerHigh,
        onRefresh: () async {
          ref.invalidate(photoFeedProvider);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
          // AppBar
          SliverPersistentHeader(
            pinned: true,
            delegate: _FeedAppBarDelegate(
              tabIndex: _selectedTab,
              onTabChanged: (i) => setState(() => _selectedTab = i),
            ),
          ),

          // Stories row
          SliverToBoxAdapter(child: _StoriesRow()),

          // Divider (tonal)
          SliverToBoxAdapter(
            child: Container(height: 1, color: AppColors.surfaceContainerHigh),
          ),

          // Post feed
          ...feedAsync.when(
            data: (photos) {
              final posts = photos.map(_MockPost.fromRow).toList();
              return <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      if (posts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.feed_outlined, size: 60, color: AppColors.onSurfaceVariant),
                                SizedBox(height: 16),
                                Text(
                                  'No posts found yet.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (i >= posts.length) return _LoadingIndicator();
                      return _PostCard(
                        key: ValueKey(posts[i].id),
                        post: posts[i],
                      );
                    },
                    childCount: posts.isEmpty ? 1 : posts.length + 1,
                  ),
                ),
              ];
            },
            loading: () => <Widget>[
              SliverFillRemaining(
                child: SkeletonFeedWidget(),
              ),
            ],
            error: (error, _) => <Widget>[
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Failed to load feed',
                    style: AppTextStyles.body,
                  ),
                ),
              ),
            ],
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      ),
    );
  }
}

// ── Mock data ─────────────────────────────────────────────────────────────────

class _MockPost {
  final String id, userId, username, displayName, imageUrl, caption;
  final int likes, comments;
  final bool isLiked;
  final String timeAgo, camera, exifShort;
  final double aspect;

  const _MockPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.timeAgo,
    required this.camera,
    required this.exifShort,
    required this.aspect,
  });

  factory _MockPost.fromRow(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map<String, dynamic>?;
    final username = profile?['username'] as String? ?? 'photographer';
    final fullName = profile?['full_name'] as String?;
    final title = row['title'] as String? ?? '';
    final caption = row['caption'] as String? ?? row['description'] as String? ?? '';
    final camera = row['camera'] as String? ?? 'Camera';
    final focalLength = row['focal_length'] as String?;
    final aperture = row['aperture'] as String?;
    final iso = row['iso'] as int?;

    return _MockPost(
      id: row['id'] as String? ?? '',
      userId: row['user_id'] as String? ?? '',
      username: username,
      displayName: (fullName != null && fullName.isNotEmpty) ? fullName : username,
      imageUrl: row['image_url'] as String? ?? '',
      caption: caption.isNotEmpty ? caption : title,
      likes: row['likes_count'] as int? ?? 0,
      comments: row['comments_count'] as int? ?? 0,
      isLiked: false,
      timeAgo: 'recent',
      camera: camera,
      exifShort: [
        if (focalLength != null && focalLength.isNotEmpty) '${focalLength}mm',
        if (aperture != null && aperture.isNotEmpty) 'f/$aperture',
        if (iso != null) 'ISO $iso',
      ].join(' · '),
      aspect: 4 / 5,
    );
  }
}

// ── Feed AppBar ───────────────────────────────────────────────────────────────

class _FeedAppBarDelegate extends SliverPersistentHeaderDelegate {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;

  _FeedAppBarDelegate({required this.tabIndex, required this.onTabChanged});

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xCC0E0E0E),
            border: Border(
              bottom: BorderSide(color: AppColors.glassBorder, width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _TabItem(title: 'For You', isSelected: tabIndex == 0, onTap: () => onTabChanged(0)),
                  const SizedBox(width: 20),
                  _TabItem(title: 'Following', isSelected: tabIndex == 1, onTap: () => onTabChanged(1)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, size: 22),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_outlined, size: 22),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _FeedAppBarDelegate oldDelegate) =>
      tabIndex != oldDelegate.tabIndex;
}

class _TabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── Stories Row ───────────────────────────────────────────────────────────────

class _StoriesRow extends StatelessWidget {
  static final _users = [
    ('Your Story', null, true),
    ('Marcus C.', 'https://i.pravatar.cc/150?img=1', false),
    ('Sarah K.', 'https://i.pravatar.cc/150?img=2', false),
    ('Rio P.', 'https://i.pravatar.cc/150?img=3', false),
    ('Alex M.', 'https://i.pravatar.cc/150?img=4', false),
    ('Lina R.', 'https://i.pravatar.cc/150?img=5', false),
    ('James T.', 'https://i.pravatar.cc/150?img=6', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        itemCount: _users.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final (name, avatar, isOwn) = _users[i];
          return _StoryBubble(
            name: name,
            avatarUrl: avatar,
            isOwn: isOwn,
          );
        },
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isOwn;

  const _StoryBubble({
    required this.name,
    this.avatarUrl,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isOwn
                ? null
                : const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDim],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isOwn ? AppColors.surfaceContainerHigh : null,
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background,
            ),
            padding: const EdgeInsets.all(2),
            child: isOwn
                ? const Icon(Icons.add, color: AppColors.primary, size: 22)
                : CircleAvatar(
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    child: avatarUrl == null
                        ? Text(name[0], style: AppTextStyles.label)
                        : null,
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name.split(' ').first,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Post Card ─────────────────────────────────────────────────────────────────

class _PostCard extends StatefulWidget {
  final _MockPost post;
  const _PostCard({super.key, required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = widget.post.isLiked;
    _likes = widget.post.likes;
  }

  void _handleDoubleTap() {
    if (!_liked) {
      setState(() {
        _liked = true;
        _likes++;
      });
    }
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final optimizedImageUrl = optimizeImageUrl(
      widget.post.imageUrl,
      width: 1400,
      quality: 76,
    );

    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────
          _PostHeader(post: widget.post),

          // ── Image ──────────────────────────────────────
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: AspectRatio(
              aspectRatio: widget.post.aspect,
              child: CachedNetworkImage(
                imageUrl: optimizedImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.surfaceContainerHigh,
                ),
              ),
            ),
          ),

          // ── EXIF strip ─────────────────────────────────
          _ExifStrip(camera: widget.post.camera, exif: widget.post.exifShort),

          // ── Actions ────────────────────────────────────
          _PostActions(
            liked: _liked,
            likeCount: _likes,
            commentCount: widget.post.comments,
            onLike: _toggleLike,
            onComment: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CommentBottomSheet(photoId: widget.post.id),
              );
            },
          ),

          // ── Caption ────────────────────────────────────
          _PostCaption(
            displayName: widget.post.displayName,
            caption: widget.post.caption,
            timeAgo: widget.post.timeAgo,
          ),

          // Spacer between posts (tonal)
          Container(height: 8, color: AppColors.surfaceContainerLow),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}

class _PostHeader extends StatelessWidget {
  final _MockPost post;
  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Avatar with gold ring
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDim],
              ),
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(
                post.displayName[0],
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.displayName, style: AppTextStyles.label),
                Text(post.timeAgo, style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 20),
            color: AppColors.onSurfaceVariant,
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ExifStrip extends StatelessWidget {
  final String camera;
  final String exif;
  const _ExifStrip({required this.camera, required this.exif});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined,
              size: 12, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(camera, style: AppTextStyles.exifLabel.copyWith(color: AppColors.primary)),
          const SizedBox(width: 8),
          Container(width: 1, height: 10, color: AppColors.outlineVariant),
          const SizedBox(width: 8),
          Text(exif, style: AppTextStyles.exifData.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  final bool liked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const _PostActions({
    required this.liked,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
    required this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _ActionBtn(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? AppColors.error : AppColors.onSurface,
            label: liked ? _fmt(likeCount) : null,
            onTap: onLike,
          ),
          _ActionBtn(
            icon: Icons.chat_bubble_outline,
            color: AppColors.onSurface,
            label: _fmt(commentCount),
            onTap: onComment,
          ),
          _ActionBtn(
            icon: Icons.send_outlined,
            color: AppColors.onSurface,
            onTap: () {},
          ),
          const Spacer(),
          _ActionBtn(
            icon: Icons.bookmark_border_outlined,
            color: AppColors.onSurface,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(label!, style: AppTextStyles.label.copyWith(color: color)),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostCaption extends StatelessWidget {
  final String displayName;
  final String caption;
  final String timeAgo;

  const _PostCaption({
    required this.displayName,
    required this.caption,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$displayName  ',
                  style: AppTextStyles.label,
                ),
                TextSpan(
                  text: caption,
                  style: AppTextStyles.body.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(timeAgo, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 1.5,
        ),
      ),
    );
  }
}
