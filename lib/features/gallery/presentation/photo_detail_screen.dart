import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/error_retry_widget.dart';
import 'package:luxlog/core/services/image_url_optimizer.dart';
import 'package:luxlog/shared/widgets/exif_badge.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';
import 'package:luxlog/features/profile/providers/user_provider.dart';

/// Module 1: Photo Detail
class PhotoDetailScreen extends ConsumerStatefulWidget {
  final String photoId;
  const PhotoDetailScreen({super.key, required this.photoId});

  @override
  ConsumerState<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends ConsumerState<PhotoDetailScreen> {
  bool _liked = false;
  bool _saved = false;
  int _likes = 0;
  bool _following = false;
  bool _likeLoading = true;
  bool _followLoading = true;
  bool _saveLoading = true;

  @override
  void initState() {
    super.initState();
  }

  void _initSocialState(Map<String, dynamic> photo) {
    if (_likeLoading) {
      _likes = photo['likes_count'] as int? ?? 0;
    }
  }

  Future<void> _toggleLike(String photoId) async {
    final repo = ref.read(photoRepositoryProvider);
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    try {
      if (_liked) {
        await repo.likePhoto(photoId);
      } else {
        await repo.unlikePhoto(photoId);
      }
    } catch (_) {
      // Revert on failure
      setState(() {
        _liked = !_liked;
        _likes += _liked ? 1 : -1;
      });
    }
  }

  Future<void> _toggleFollow(String targetUserId) async {
    final userRepo = ref.read(userRepositoryProvider);
    setState(() => _following = !_following);
    try {
      if (_following) {
        await userRepo.followUser(targetUserId);
      } else {
        await userRepo.unfollowUser(targetUserId);
      }
    } catch (_) {
      setState(() => _following = !_following);
    }
  }

  void _sharePhoto(String title, String photoId) {
    final url = 'https://luxlog.app/photo/$photoId';
    Share.share('$title\n$url');
  }

  Future<void> _toggleSave(String photoId) async {
    final repo = ref.read(photoRepositoryProvider);
    setState(() => _saved = !_saved);
    try {
      if (_saved) {
        await repo.savePhoto(photoId);
      } else {
        await repo.unsavePhoto(photoId);
      }
    } catch (_) {
      setState(() => _saved = !_saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: ref.watch(photoDetailProvider(widget.photoId)).when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => ErrorRetryWidget(
          message: 'Failed to load photo',
          onRetry: () => ref.invalidate(photoDetailProvider(widget.photoId)),
        ),
        data: (photo) {
          final profile = photo['profiles'] as Map<String, dynamic>?;
          final username = profile?['username'] as String? ?? 'photographer';
          final fullName = profile?['full_name'] as String?;
          final displayName = (fullName != null && fullName.isNotEmpty) ? fullName : username;
          final avatarUrl = profile?['avatar_url'] as String?;
          final userId = photo['user_id'] as String? ?? '';
          final title = photo['title'] as String? ?? '';
          final caption = photo['caption'] as String? ?? photo['description'] as String? ?? '';
          final imageUrl = photo['image_url'] as String? ?? '';

          _initSocialState(photo);

          // Load like state from server
          ref.listen(photoLikeStateProvider(widget.photoId), (_, next) {
            next.whenData((liked) {
              if (_likeLoading) {
                setState(() { _liked = liked; _likeLoading = false; });
              }
            });
          });
          // Eagerly watch so the provider actually runs
          ref.watch(photoLikeStateProvider(widget.photoId));

          // Load follow state from server
          if (userId.isNotEmpty) {
            ref.listen(photoFollowStateProvider(userId), (_, next) {
              next.whenData((following) {
                if (_followLoading) {
                  setState(() { _following = following; _followLoading = false; });
                }
              });
            });
            ref.watch(photoFollowStateProvider(userId));
          }

          // Load save state from server
          ref.listen(photoSaveStateProvider(widget.photoId), (_, next) {
            next.whenData((saved) {
              if (_saveLoading) {
                setState(() { _saved = saved; _saveLoading = false; });
              }
            });
          });
          ref.watch(photoSaveStateProvider(widget.photoId));
          final optimizedImageUrl = optimizeImageUrl(
            imageUrl,
            width: 1800,
            quality: 80,
          );
          final camera = photo['camera'] as String? ?? 'Camera';
          final focalLength = photo['focal_length'] as String?;
          final aperture = photo['aperture'] as String?;
          final iso = photo['iso'] as int?;

          final dynamicExif = ExifInfo(
            camera: camera,
            lens: photo['lens'] as String?,
            iso: iso,
            aperture: aperture,
            shutterSpeed: photo['shutter_speed'] as String?,
            focalLength: focalLength != null ? double.tryParse(focalLength.replaceAll(RegExp(r'[^0-9.]'), '')) : null,
            takenAt: null,
          );

          return CustomScrollView(
            slivers: [
              // ── Back button appbar ────────────────────────────
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: false,
                floating: true,
                leading: _GlassBackButton(),
                actions: [
                  Semantics(
                    button: true,
                    label: 'Share photo',
                    child: _GlassIconButton(
                      icon: Icons.share_outlined,
                      onTap: () => _sharePhoto(title, widget.photoId),
                    ),
                  ),
                  _GlassIconButton(
                    icon: Icons.more_horiz,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // ── Hero: Full-width photo ────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    minHeight: 280,
                  ),
                  color: AppColors.surfaceContainerLowest,
                  child: CachedNetworkImage(
                    imageUrl: optimizedImageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // ── Photo info card ───────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.surface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Photographer + actions
                      _PhotographerRow(
                        displayName: displayName,
                        username: username,
                        avatarUrl: avatarUrl,
                        liked: _liked,
                        saved: _saved,
                        likeCount: _likes,
                        following: _following,
                        onLike: () => _toggleLike(widget.photoId),
                        onSave: () => _toggleSave(widget.photoId),
                        onFollow: userId.isNotEmpty ? () => _toggleFollow(userId) : null,
                        onTapProfile: () => context.push('/u/$username'),
                      ),

                      // Title
                      if (title.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: Text(
                            title,
                            style: AppTextStyles.sectionHeader,
                          ).animate().fadeIn(delay: 100.ms),
                        ),

                      // Description
                      if (caption.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Text(
                            caption,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.onSurfaceVariant,
                              height: 1.6,
                            ),
                          ),
                        ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: ExifDataGrid(exif: dynamicExif),
                  ),

                  // Divider
                  Container(
                    height: 8,
                    color: AppColors.surfaceContainerLow,
                  ),

                  // Stats row
                  _StatsRow(likes: _likes),

                  // Comments section
                  _CommentsSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Related photos ────────────────────────────────
          SliverToBoxAdapter(
            child: _RelatedPhotos(photoId: widget.photoId),
          ),
        ],
      );
    }),
    );
  }
}

class _PhotographerRow extends StatelessWidget {
  final String displayName;
  final String username;
  final String? avatarUrl;
  final bool liked;
  final bool saved;
  final int likeCount;
  final bool following;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback? onFollow;
  final VoidCallback? onTapProfile;

  const _PhotographerRow({
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.liked,
    required this.saved,
    required this.likeCount,
    required this.following,
    required this.onLike,
    required this.onSave,
    this.onFollow,
    this.onTapProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar — tappable to profile
          GestureDetector(
            onTap: onTapProfile,
            child: Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDim],
              ),
            ),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null 
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: AppTextStyles.headline.copyWith(color: AppColors.primary),
                  )
                : null,
            ),
          ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onTapProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: AppTextStyles.titleMedium),
                  Text(
                    '@$username',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          // Follow button
          Semantics(
            button: true,
            label: following ? 'Unfollow $displayName' : 'Follow $displayName',
            child: OutlinedButton(
              onPressed: onFollow,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: following ? AppColors.primary : null,
                foregroundColor: following ? AppColors.onPrimary : null,
              ),
              child: Text(following ? 'Following' : 'Follow'),
            ),
          ),
          const SizedBox(width: 8),
          // Like
          _ActionButton(
            icon: liked ? Icons.favorite : Icons.favorite_border,
            color: liked ? AppColors.error : AppColors.onSurfaceVariant,
            count: likeCount,
            onTap: onLike,
          ),
          const SizedBox(width: 4),
          // Save
          _ActionButton(
            icon: saved ? Icons.bookmark : Icons.bookmark_border_outlined,
            color: saved ? AppColors.primary : AppColors.onSurfaceVariant,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int? count;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                _fmt(count!),
                style: AppTextStyles.label.copyWith(color: color),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
}

// ── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int likes;
  const _StatsRow({required this.likes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _Stat(value: '$likes', label: 'likes'),
          const SizedBox(width: 24),
          _Stat(value: '18.4k', label: 'views'),
          const SizedBox(width: 24),
          _Stat(value: '342', label: 'downloads'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.exifData.copyWith(
          fontSize: 18,
          color: AppColors.onSurface,
        )),
        Text(label, style: AppTextStyles.exifLabel),
      ],
    );
  }
}

// ── Comments ─────────────────────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: AppColors.surfaceContainerHigh),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('Comments', style: AppTextStyles.titleMedium),
        ),
        // Comment input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryContainer,
                child: Text('A',
                    style: AppTextStyles.exifLabel
                        .copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add a comment...',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Sample comments
        ...List.generate(3, (i) => _CommentItem(index: i)),
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  final int index;
  const _CommentItem({required this.index});

  static const _comments = [
    ('Sarah K.', 'Absolutely stunning! The bokeh is silky smooth 😍'),
    ('Alex M.', 'Which filter did you use? The colors are incredible.'),
    ('Rio P.', 'The 35GM is such a phenomenal lens, great shot!'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = _comments[index % _comments.length];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceContainerHighest,
            child: Text(
              c.$1[0],
              style: AppTextStyles.exifLabel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.$1, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(c.$2, style: AppTextStyles.body.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Related Photos ────────────────────────────────────────────────────────────

class _RelatedPhotos extends StatelessWidget {
  final String photoId;
  const _RelatedPhotos({required this.photoId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text('More like this', style: AppTextStyles.titleLarge),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://picsum.photos/seed/rel_${photoId}_$i/400/400',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Glass back button ────────────────────────────────────────────────────────

class _GlassBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
