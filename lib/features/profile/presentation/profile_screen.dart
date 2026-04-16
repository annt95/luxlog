import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeshot/app/theme.dart';

/// User Profile Screen — portfolio preview + photo grid + bio
class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isFollowing = false;
  static const _tabs = ['Photos', 'Portfolio', 'Collections', 'Gear'];

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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Collapsing cover + profile info
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
                username: widget.username,
                isFollowing: _isFollowing,
                onFollow: () => setState(() => _isFollowing = !_isFollowing),
              ),
            ),
          ),

          // Sticky tab bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(tabCtrl: _tabCtrl, tabs: _tabs),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _PhotosTab(username: widget.username),
            _PortfolioTab(username: widget.username),
            _CollectionsTab(),
            _GearTab(),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String username;
  final bool isFollowing;
  final VoidCallback onFollow;

  const _ProfileHeader({
    required this.username,
    required this.isFollowing,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
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
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=$username',
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Buttons
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
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Name
                Text(
                  '@$username',
                  style: AppTextStyles.sectionHeader.copyWith(fontSize: 20),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 4),
                // Bio
                Text(
                  'Documentary & Street Photographer · Sony Alpha · Tokyo 🇯🇵',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 14),
                // Stats
                Row(
                  children: [
                    _StatBadge(value: '2.4k', label: 'Photos'),
                    const SizedBox(width: 20),
                    _StatBadge(value: '14.2k', label: 'Followers'),
                    const SizedBox(width: 20),
                    _StatBadge(value: '312', label: 'Following'),
                    const SizedBox(width: 20),
                    _StatBadge(value: '847k', label: 'Views'),
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
  const _PhotosTab({required this.username});

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 3,
      crossAxisSpacing: 3,
      padding: const EdgeInsets.fromLTRB(3, 3, 3, 96),
      itemCount: 24,
      itemBuilder: (context, i) {
        final aspects = [1.0, 0.75, 1.25, 0.85, 1.1, 0.7];
        return GestureDetector(
          onTap: () => context.push('/photo/${username}_photo_$i'),
          child: AspectRatio(
            aspectRatio: aspects[i % aspects.length],
            child: CachedNetworkImage(
              imageUrl: 'https://picsum.photos/seed/${username}_$i/400/400',
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppColors.surfaceContainerHigh),
            ),
          ),
        ).animate(delay: Duration(milliseconds: i * 20)).fadeIn();
      },
    );
  }
}

// ── Portfolio Tab ─────────────────────────────────────────────────────────────

class _PortfolioTab extends StatelessWidget {
  final String username;
  const _PortfolioTab({required this.username});

  static const _projects = [
    ('Tokyo After Rain', 'Street Documentary', 24),
    ('Faces of Shinjuku', 'Portrait Series', 16),
    ('Neon Nights', 'Urban Nightlife', 32),
    ('Silent Gardens', 'Nature & Zen', 12),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: _projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = _projects[i];
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
                    imageUrl: 'https://picsum.photos/seed/${username}_proj_$i/800/400',
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
                        Text(p.$1, style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(p.$2,
                                  style: AppTextStyles.exifLabel
                                      .copyWith(color: AppColors.primary)),
                            ),
                            const SizedBox(width: 8),
                            Text('${p.$3} photos',
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate(delay: Duration(milliseconds: i * 80)).fadeIn().slideY(begin: 0.05);
      },
    );
  }
}

// ── Collections Tab ──────────────────────────────────────────────────────────

class _CollectionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: 8,
      itemBuilder: (context, i) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: 'https://picsum.photos/seed/col_$i/400/300',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Text('Collection ${i + 1}', style: AppTextStyles.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gear Tab ─────────────────────────────────────────────────────────────────

class _GearTab extends StatelessWidget {
  static const _gear = [
    (Icons.camera_alt_outlined, 'Camera Body', 'Sony α7 IV'),
    (Icons.lens_outlined, 'Prime Lens', 'Sony FE 35mm f/1.4 GM'),
    (Icons.lens_outlined, 'Zoom Lens', 'Sony FE 24-70mm f/2.8 GM II'),
    (Icons.camera_outlined, 'Film Camera', 'Contax G2'),
    (Icons.sd_card_outlined, 'Memory', 'Sony CFexpress Type A 160GB'),
    (Icons.settings_outlined, 'Editing', 'Adobe Lightroom Classic'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: _gear.length,
      separatorBuilder: (_, __) => Container(
        height: 1, color: AppColors.surfaceContainerHigh,
      ),
      itemBuilder: (context, i) {
        final g = _gear[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(4),
                  border: const Border(
                    left: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                child: Icon(g.$1, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.$2, style: AppTextStyles.exifLabel),
                    Text(g.$3, style: AppTextStyles.titleMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.onSurfaceVariant, size: 18),
            ],
          ),
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
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
