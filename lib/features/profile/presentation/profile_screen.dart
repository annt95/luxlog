import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/features/profile/providers/follow_state_provider.dart';
import 'package:luxlog/features/profile/providers/user_provider.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';
import 'package:luxlog/features/portfolio/providers/portfolio_provider.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';

/// User Profile Screen — portfolio preview + photo grid + bio
class ProfileScreen extends ConsumerStatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  static const _tabs = ['Photos', 'Portfolio'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.username == 'me') {
      final user = ref.watch(currentUserProvider);
      if (user == null) {
        return const _GuestProfileView();
      }
    }

    final profileAsync = widget.username == 'me'
        ? ref.watch(currentUserProfileProvider)
        : ref.watch(userProfileProvider(widget.username));

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              e.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
      data: (profile) {
        final profileUsername = profile['username'] as String? ?? widget.username;
        final profileId = profile['id'] as String?;
        final isOwnProfile = widget.username == 'me';
        final isFollowing = ref.watch(followStateProvider).contains(profileUsername);
        final photoRepository = ref.watch(photoRepositoryProvider);
        final statsFuture = profileId == null
            ? Future.value(const [0, 0])
            : Future.wait<int>([
                photoRepository.countByUser(profileId),
                photoRepository.totalViewsByUser(profileId),
              ]);

        return FutureBuilder<List<int>>(
          future: statsFuture,
          builder: (context, statsSnapshot) {
            final photoCount = statsSnapshot.data?.first ?? 0;
            final viewsCount = statsSnapshot.data?.length == 2
                ? statsSnapshot.data![1]
                : 0;

            return Scaffold(
              backgroundColor: AppColors.background,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: 340,
                    pinned: true,
                    backgroundColor: AppColors.background,
                    elevation: 0,
                    leading: _GlassIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    actions: [
                      _GlassIconButton(icon: Icons.share_outlined, onTap: () {}),
                      _GlassIconButton(icon: Icons.more_horiz, onTap: () {}),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: _ProfileHeader(
                        profile: profile,
                        isFollowing: isFollowing,
                        showFollowActions: !isOwnProfile,
                        photoCount: photoCount,
                        viewsCount: viewsCount,
                        onFollow: () => ref
                            .read(followStateProvider.notifier)
                            .toggleFollow(profileUsername),
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(tabCtrl: _tabCtrl, tabs: _tabs),
                  ),
                ],
                body: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _PhotosTab(username: profileUsername, profileId: profileId),
                    _PortfolioTab(
                      username: profileUsername,
                      profileId: profileId,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;
  final bool isFollowing;
  final bool showFollowActions;
  final int photoCount;
  final int viewsCount;
  final VoidCallback onFollow;

  const _ProfileHeader({
    required this.profile,
    required this.isFollowing,
    required this.showFollowActions,
    required this.photoCount,
    required this.viewsCount,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final username = profile['username'] as String? ?? 'user';
    final fullName = profile['full_name'] as String?;
    final avatarUrl = profile['avatar_url'] as String?;
    final bio = profile['bio'] as String? ?? '';
    final followers = profile['followers'] as List<dynamic>?;
    final following = profile['following'] as List<dynamic>?;
    final followersCount = followers != null &&
            followers.isNotEmpty &&
            followers.first is Map<String, dynamic>
        ? (followers.first as Map<String, dynamic>)['count'] as int? ?? 0
        : 0;
    final followingCount = following != null &&
            following.isNotEmpty &&
            following.first is Map<String, dynamic>
        ? (following.first as Map<String, dynamic>)['count'] as int? ?? 0
        : 0;

    return Stack(
      children: [
        // Cover image
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: 'https://picsum.photos/seed/${username}_cover/800/400',
            fit: BoxFit.cover,
          ),
        ),
        // Dark gradient
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xEE0E0E0E)],
                stops: [0.4, 1.0],
              ),
            ),
          ),
        ),
        // Profile content
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + follow button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar with gold border
                    Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDim],
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundColor: AppColors.surfaceContainerHigh,
                        backgroundImage:
                            avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                            ? Text(
                                username.isNotEmpty
                                    ? username[0].toUpperCase()
                                    : 'U',
                                style: AppTextStyles.label,
                              )
                            : null,
                      ),
                    ),
                    const Spacer(),
                    if (showFollowActions)
                      Row(
                        children: [
                          _ProfileButton(
                            label: isFollowing ? 'Following' : 'Follow',
                            isPrimary: !isFollowing,
                            onTap: onFollow,
                          ),
                          const SizedBox(width: 8),
                          _ProfileButton(
                            label: 'Message',
                            isPrimary: false,
                            onTap: () {},
                          ),
                        ],
                      )
                    else
                      _ProfileButton(
                        label: 'Edit Profile',
                        isPrimary: false,
                        onTap: () => context.push('/profile/edit'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Name
                if (fullName != null && fullName.isNotEmpty) ...[
                  Text(
                    fullName,
                    style: AppTextStyles.sectionHeader.copyWith(fontSize: 22),
                  ).animate().fadeIn(delay: 50.ms),
                  Text(
                    '@$username',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ] else ...[
                  Text(
                    '@$username',
                    style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
                  ).animate().fadeIn(delay: 100.ms),
                ],
                const SizedBox(height: 8),
                // Bio
                Text(
                  bio.isEmpty
                      ? 'Photographer on Luxlog'
                      : bio,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                // Stats
                Row(
                  children: [
                    _StatBadge(value: '$photoCount', label: 'Photos'),
                    const SizedBox(width: 20),
                    _StatBadge(value: '$followersCount', label: 'Followers'),
                    const SizedBox(width: 20),
                    _StatBadge(value: '$followingCount', label: 'Following'),
                    const SizedBox(width: 20),
                    _StatBadge(value: '$viewsCount', label: 'Views'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ProfileButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isPrimary ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: isPrimary ? AppColors.onPrimary : AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  const _StatBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: AppTextStyles.exifData.copyWith(
              fontSize: 16,
              color: AppColors.onSurface,
            )),
        Text(label, style: AppTextStyles.exifLabel),
      ],
    );
  }
}

// ── Tab Bar delegate ──────────────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabCtrl;
  final List<String> tabs;
  const _TabBarDelegate({required this.tabCtrl, required this.tabs});

  @override
  double get minExtent => 44;
  @override
  double get maxExtent => 44;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: const Color(0xDD0E0E0E),
          child: TabBar(
            controller: tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: AppTextStyles.exifData,
            unselectedLabelStyle: AppTextStyles.exifData,
            dividerColor: AppColors.outlineVariant,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => false;
}

// ── Photos Tab ───────────────────────────────────────────────────────────────

class _PhotosTab extends StatelessWidget {
  final String username;
  final String? profileId;

  const _PhotosTab({
    required this.username,
    required this.profileId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        if (profileId == null) {
          return const Center(child: Text('No photos yet'));
        }
        final repository = ref.watch(photoRepositoryProvider);
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: repository.fetchByUser(userId: profileId!, page: 0, limit: 60),
          builder: (context, snapshot) {
            if (!snapshot.hasData && !snapshot.hasError) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Failed to load photos'));
            }
            final ownPhotos = snapshot.data ?? const [];
            if (ownPhotos.isEmpty) {
              return const Center(child: Text('No photos yet'));
            }
            return MasonryGridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              padding: const EdgeInsets.fromLTRB(3, 3, 3, 96),
              itemCount: ownPhotos.length,
              itemBuilder: (context, i) {
                final photo = ownPhotos[i];
                return GestureDetector(
                  onTap: () => context.push('/photo/${photo['id']}'),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: photo['image_url'] as String? ?? '',
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.surfaceContainerHigh),
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: i * 20)).fadeIn();
              },
            );
          },
        );
      },
    );
  }
}

// ── Portfolio Tab ─────────────────────────────────────────────────────────────

class _PortfolioTab extends StatelessWidget {
  final String username;
  final String? profileId;
  const _PortfolioTab({required this.username, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        if (profileId == null) {
          return const Center(child: Text('No portfolio yet'));
        }
        final blocksAsync = ref.watch(portfolioBlocksProvider(profileId!));
        return blocksAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => const Center(child: Text('Failed to load portfolio')),
          data: (blocks) {
            if (blocks.isEmpty) {
              return const Center(child: Text('No portfolio yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: blocks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final block = blocks[i];
                final title = block['title'] as String? ?? 'Portfolio block';
                final subtitle =
                    block['type'] as String? ?? 'Creative work';
                final cover =
                    block['image_url'] as String? ??
                    block['cover_image'] as String? ??
                    'https://picsum.photos/seed/${username}_proj_$i/800/400';
                return GestureDetector(
                  onTap: () => context.push('/portfolio/edit/${username}_proj_$i'),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.surfaceContainerLow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: cover,
                            fit: BoxFit.cover,
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xDD000000)],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: AppTextStyles.titleMedium),
                                const SizedBox(height: 4),
                                Text(subtitle, style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    .animate(delay: Duration(milliseconds: i * 80))
                    .fadeIn()
                    .slideY(begin: 0.05);
              },
            );
          },
        );
      },
    );
  }
}

// ── Glass icon button ─────────────────────────────────────────────────────────

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

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 80, color: AppColors.onSurfaceVariant),
              const SizedBox(height: 24),
              Text(
                'Bạn chưa đăng nhập',
                style: AppTextStyles.sectionHeader.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 12),
              Text(
                'Vui lòng đăng nhập để xem hồ sơ, portfolio và tương tác với các nhiếp ảnh gia khác.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => context.pushNamed('login'),
                  child: const Text('Đăng nhập'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  onPressed: () => context.pushNamed('signup'),
                  child: const Text('Tạo tài khoản'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
