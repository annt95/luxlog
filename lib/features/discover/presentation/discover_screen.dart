import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/photo_card.dart';

/// Module 4: Discover Feed — based on Stitch "Luxlog Feed - Desktop/Mobile"
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final ScrollController _scrollController = ScrollController();
  int _selectedFilter = 0;

  static const _filters = [
    'All',
    'Trending',
    'Portrait',
    'Landscape',
    'Street',
    'Architecture',
    'Film',
    'Wildlife',
  ];

  // Mock data — replace with Supabase query
  static final _mockPhotos = List.generate(24, (i) => (
    id: 'photo_$i',
    url: 'https://picsum.photos/seed/$i/800/${600 + (i % 3) * 100}',
    photographer: 'Photographer ${i + 1}',
    avatar: null as String?,
    title: i % 3 == 0 ? 'Into the Light #$i' : null,
    likes: 120 + i * 17,
    aspect: i % 5 == 0 ? 3 / 4.0 : (i % 3 == 0 ? 4 / 3.0 : 1.0),
  ));

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Glassmorphism AppBar ─────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _GlassAppBarDelegate(),
          ),

          // ── Filter chips ─────────────────────────────────
          SliverToBoxAdapter(
            child: _FilterRow(
              filters: _filters,
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: _crossAxisCount(context),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childCount: _mockPhotos.length,
              itemBuilder: (context, i) {
                final p = _mockPhotos[i];
                return PhotoCard(
                  photoId: p.id,
                  imageUrl: p.url,
                  photographerName: p.photographer,
                  photographerAvatar: p.avatar,
                  title: p.title,
                  likes: p.likes,
                  aspectRatio: p.aspect,
                );
              },
            ),
          ),
        ],
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
  @override
  double get minExtent => 56 + 0;
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
                  // Search
                  IconButton(
                    icon: const Icon(Icons.search, size: 22),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {},
                  ),
                  // Notifications
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, size: 22),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {},
                  ),
                  // Avatar
                  const SizedBox(width: 4),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      'A',
                      style: AppTextStyles.exifData.copyWith(
                        color: AppColors.primary,
                      ),
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
                      ? AppColors.primary.withOpacity(0.5)
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
