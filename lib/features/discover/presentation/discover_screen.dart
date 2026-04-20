import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/features/profile/providers/user_provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/photo_card.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';
import 'package:luxlog/features/tags/providers/category_provider.dart';
import 'package:shimmer/shimmer.dart';

/// Module 4: Discover Feed — based on Stitch "Luxlog Feed - Desktop/Mobile"
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    // Categories will be loaded via provider
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load categories for filter chips
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <Map<String, dynamic>>[];
    final filters = [
      'All',
      'Trending',
      ...categories.map((c) => c['name'] as String? ?? 'Unknown'),
    ];
    if (_selectedFilter >= filters.length) {
      _selectedFilter = 0;
    }

    // Load photo feed
    final feedAsync = ref.watch(photoFeedProvider(page: 0, limit: 24));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerHigh,
        onRefresh: () async {
          ref.invalidate(photoFeedProvider);
          ref.invalidate(categoriesProvider);
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
          // ── Glassmorphism AppBar ─────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _GlassAppBarDelegate(ref: ref),
          ),

          // ── Filter chips ─────────────────────────────────
          SliverToBoxAdapter(
            child: _FilterRow(
              filters: filters,
              selected: _selectedFilter,
              onSelect: (i) => setState(() => _selectedFilter = i),
            ),
          ),

          // ── Hero section ──────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroSection(),
          ),

          // ── Section header ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Text("Editor's Pick", style: AppTextStyles.sectionHeader),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CURATED',
                      style: AppTextStyles.exifLabel.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Masonry Grid ──────────────────────────────────
          feedAsync.when(
            data: (photos) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: _crossAxisCount(context),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: photos.length,
                itemBuilder: (context, i) {
                  final p = photos[i];
                  final profile = p['profiles'] as Map<String, dynamic>?;
                  final fullName = profile?['full_name'] as String?;
                  final username = profile?['username'] as String? ?? 'Unknown';
                  return PhotoCard(
                    photoId: p['id'] as String,
                    imageUrl: p['image_url'] as String? ?? '',
                    photographerName: (fullName != null && fullName.isNotEmpty) ? fullName : username,
                    photographerAvatar: profile?['avatar_url'] as String?,
                    title: p['title'] as String?,
                    likes: p['likes_count'] as int? ?? 0,
                    aspectRatio: (p['aspect_ratio'] as num?)?.toDouble() ?? 1.0,
                    camera: p['camera'] as String? ?? p['film_camera'] as String?,
                    filmStock: p['film_stock'] as String?,
                    lens: p['lens'] as String?,
                  );
                },
              ),
            ),
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: _crossAxisCount(context),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: 6,
                itemBuilder: (context, i) {
                  final heights = [200.0, 260.0, 180.0, 240.0, 220.0, 280.0];
                  return Shimmer.fromColors(
                    baseColor: AppColors.surfaceContainerHigh,
                    highlightColor: AppColors.surfaceContainerHighest,
                    child: Container(
                      height: heights[i % heights.length],
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error loading feed', style: TextStyle(color: AppColors.onSurfaceVariant))),
            ),
          ),
        ],
      ),
      ),
    );
  }

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return 4;
    if (w > 800) return 3;
    if (w > 500) return 2;
    return 2;
  }
}

// ── Glassmorphism AppBar ─────────────────────────────────────────────────────

class _GlassAppBarDelegate extends SliverPersistentHeaderDelegate {
  final WidgetRef ref;
  _GlassAppBarDelegate({required this.ref});

  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 72;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: maxExtent,
          decoration: const BoxDecoration(
            color: Color(0xCC0E0E0E), // surface at 80% opacity
            border: Border(
              bottom: BorderSide(
                color: AppColors.glassBorder,
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Logo — asymmetric left
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryDim,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: AppColors.onPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Luxlog',
                        style: AppTextStyles.titleLarge.copyWith(
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Search — tạm ẩn theo yêu cầu
                  // IconButton(
                  //   icon: const Icon(Icons.search, size: 22),
                  //   color: AppColors.onSurfaceVariant,
                  //   onPressed: () {},
                  // ),
                  // Notifications — tạm ẩn theo yêu cầu
                  // IconButton(
                  //   icon: const Icon(Icons.notifications_outlined, size: 22),
                  //   color: AppColors.onSurfaceVariant,
                  //   onPressed: () => context.push('/notifications'),
                  // ),
                  // Avatar
                  const SizedBox(width: 4),
                  ref.watch(currentUserProfileProvider).when(
                        data: (profile) {
                          final name = profile['full_name'] as String? ?? profile['username'] as String? ?? 'U';
                          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
                          return CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryContainer,
                            child: Text(
                              initial,
                              style: AppTextStyles.exifData.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                        loading: () => const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.surfaceContainerHigh,
                        ),
                        error: (_, __) => const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: Icon(Icons.person, size: 16),
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
  bool shouldRebuild(covariant _GlassAppBarDelegate oldDelegate) => false;
}

// ── Filter chips ─────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onSelect;

  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                filters[i],
                style: AppTextStyles.exifData.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Hero Section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppColors.surfaceContainerLowest,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Hero image
            Image.network(
              'https://picsum.photos/seed/hero/1200/600',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceContainerHigh,
              ),
            ),
            // Gradient overlay
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                      border: const Border(
                        left: BorderSide(
                            color: AppColors.primary, width: 2),
                      ),
                    ),
                    child: Text(
                      "EDITOR'S PICK",
                      style: AppTextStyles.exifLabel.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The Golden Hour',
                    style: AppTextStyles.sectionHeader.copyWith(
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                  const SizedBox(height: 4),
                  Text(
                    'by Marcus Chen · Sony A7IV · ƒ/1.8 · ISO 400',
                    style: AppTextStyles.exifData.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
