import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/error_retry_widget.dart';
import 'package:luxlog/core/services/image_url_optimizer.dart';
import 'package:luxlog/features/gallery/presentation/widgets/comment_bottom_sheet.dart';
import 'package:luxlog/shared/widgets/skeleton_widgets.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';
import 'package:luxlog/features/gallery/providers/paginated_feed_notifier.dart';

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
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      // Near bottom — trigger load more
      if (_selectedTab == 0) {
        ref.read(paginatedFeedProvider.notifier).loadMore();
      } else {
        ref.read(paginatedFollowFeedProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<PaginatedFeedState> feedAsync;
    if (_selectedTab == 1) {
      feedAsync = ref.watch(paginatedFollowFeedProvider);
    } else {
      feedAsync = ref.watch(paginatedFeedProvider);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerHigh,
        onRefresh: () async {
          if (_selectedTab == 0) {
            await ref.read(paginatedFeedProvider.notifier).refresh();
          } else {
            await ref.read(paginatedFollowFeedProvider.notifier).refresh();
          }
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
            data: (feedState) {
              final posts = feedState.items.map(_MockPost.fromRow).toList();
              if (posts.isEmpty) {
                return <Widget>[
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                  ),
                ];
              }
              return <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      // Last item: show loading indicator if loading more
                      if (i == posts.length) {
                        return feedState.hasMore
                            ? const _LoadMoreIndicator()
                            : const _EndOfFeedIndicator();
                      }
                      return _PostCard(
                        key: ValueKey(posts[i].id),
                        post: posts[i],
                      );
                    },
                    childCount: posts.length + 1,
                  ),
                ),
              ];
            },
            loading: () => <Widget>[
              const SliverFillRemaining(
                child: SkeletonFeedWidget(),
              ),
            ],
            error: (error, _) => <Widget>[
              SliverFillRemaining(
                child: ErrorRetryWidget(
                  message: 'Failed to load feed',
                  onRetry: () {
                    if (_selectedTab == 0) {
                      ref.read(paginatedFeedProvider.notifier).refresh();
                    } else {
                      ref.read(paginatedFollowFeedProvider.notifier).refresh();
                    }
                  },
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

// ── Load More / End indicators ────────────────────────────────────────────────

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _EndOfFeedIndicator extends StatelessWidget {
  const _EndOfFeedIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 20, height: 1, color: AppColors.outlineVariant),
          const SizedBox(width: 8),
          Text(
            'You\'re all caught up',
            style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Container(width: 20, height: 1, color: AppColors.outlineVariant),
        ],
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
    final caption = row['caption'] as String? ?? (row['description'] is String ? row['description'] as String : '');
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
                    onPressed: () => context.push('/notifications'),
                  ),
                  Tooltip(
                    message: 'Coming soon',
                    child: IconButton(
                      icon: const Icon(Icons.send_outlined, size: 22),
                      color: AppColors.onSurfaceVariant,
                      onPressed: () {},
                    ),
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
    ('Marcus C.', 'https://ui-avatars.com/api/?name=Marcus+C&background=random', false),
    ('Sarah K.', 'https://ui-avatars.com/api/?name=Sarah+K&background=random', false),
    ('Rio P.', 'https://ui-avatars.com/api/?name=Rio+P&background=random', false),
    ('Alex M.', 'https://ui-avatars.com/api/?name=Alex+M&background=random', false),
    ('Lina R.', 'https://ui-avatars.com/api/?name=Lina+R&background=random', false),
    ('James T.', 'https://ui-avatars.com/api/?name=James+T&background=random', false),
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
                    onBackgroundImageError: avatarUrl != null
                        ? (exception, stackTrace) {
                            debugPrint('Error loading avatar: $exception');
                          }
                        : null,
                    child: avatarUrl == null
                        ? Text(name[0], style: AppTextStyles.label)
                        : null,
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name.isNotEmpty ? name.split(' ').first : 'User',
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Post Card ─────────────────────────────────────────────────────────────────

class _PostCard extends ConsumerStatefulWidget {
  final _MockPost post;
  const _PostCard({super.key, required this.post});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
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
      _toggleLike();
    }
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    // Fire-and-forget to backend
    final repo = ref.read(photoRepositoryProvider);
    if (_liked) {
      repo.likePhoto(widget.post.id).catchError((_) {
        if (mounted) setState(() { _liked = false; _likes--; });
      });
    } else {
      repo.unlikePhoto(widget.post.id).catchError((_) {
        if (mounted) setState(() { _liked = true; _likes++; });
      });
    }
  }

  void _sharePost() {
    final url = 'https://luxlog.app/photo/${widget.post.id}';
    Share.share('${widget.post.caption}\n$url');
  }

  void _toggleSave() {
    final repo = ref.read(photoRepositoryProvider);
    final currentState = ref.read(photoSaveStateProvider(widget.post.id));
    final wasSaved = currentState.valueOrNull ?? false;

    if (wasSaved) {
      repo.unsavePhoto(widget.post.id).then((_) {
        ref.invalidate(photoSaveStateProvider(widget.post.id));
      }).catchError((_) {});
    } else {
      repo.savePhoto(widget.post.id).then((_) {
        ref.invalidate(photoSaveStateProvider(widget.post.id));
      }).catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch save state reactively — no N+1 initState calls
    final saveAsync = ref.watch(photoSaveStateProvider(widget.post.id));
    final saved = saveAsync.valueOrNull ?? false;

    final optimizedImageUrl = optimizeImageUrl(
      widget.post.imageUrl,
      width: 800,
      quality: 76,
    );

    Widget card = Container(
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
              child: kIsWeb
                  ? Image.network(
                      optimizedImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: AppColors.onSurfaceVariant, size: 32),
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: optimizedImageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 800,
                      placeholder: (_, __) => Container(
                        color: AppColors.surfaceContainerHigh,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerHigh,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined,
                              color: AppColors.onSurfaceVariant, size: 32),
                        ),
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
            onShare: _sharePost,
            saved: saved,
            onSave: _toggleSave,
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
    );

    // Skip heavy animations on Web to avoid jank
    if (kIsWeb) return card;
    return card.animate().fadeIn(duration: 250.ms);
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
          // Avatar with gold ring — tappable to profile
          GestureDetector(
            onTap: () => context.push('/u/${post.username}'),
            child: Container(
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
                post.displayName.isNotEmpty ? post.displayName[0] : '?',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/u/${post.username}'),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.displayName, style: AppTextStyles.label),
                Text(post.timeAgo, style: AppTextStyles.caption),
              ],
            ),
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
  final VoidCallback? onShare;
  final bool saved;
  final VoidCallback? onSave;

  const _PostActions({
    required this.liked,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
    required this.onComment,
    this.onShare,
    this.saved = false,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Semantics(button: true, label: liked ? 'Unlike, $likeCount likes' : 'Like, $likeCount likes', child:
          _ActionBtn(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? AppColors.error : AppColors.onSurface,
            label: liked ? _fmt(likeCount) : null,
            onTap: onLike,
          )),
          Semantics(button: true, label: '$commentCount comments', child:
          _ActionBtn(
            icon: Icons.chat_bubble_outline,
            color: AppColors.onSurface,
            label: _fmt(commentCount),
            onTap: onComment,
          )),
          Semantics(button: true, label: 'Share', child:
          _ActionBtn(
            icon: Icons.send_outlined,
            color: AppColors.onSurface,
            onTap: onShare ?? () {},
          )),
          const Spacer(),
          Semantics(button: true, label: saved ? 'Unsave photo' : 'Save photo', child:
          _ActionBtn(
            icon: saved ? Icons.bookmark : Icons.bookmark_border_outlined,
            color: saved ? AppColors.primary : AppColors.onSurface,
            onTap: onSave ?? () {},
          )),
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
