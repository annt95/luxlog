import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/tag_chip.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';
import 'package:luxlog/features/tags/providers/tag_provider.dart';

/// Explore / Search screen
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final TabController _tabCtrl;
  bool _searching = false;
  String _query = '';

  static const _tabs = ['Photos', 'People', 'Collections', 'Gear'];

  static const _genres = [
    ('Portrait', Icons.person_outline, 'https://picsum.photos/seed/g1/300/300'),
    ('Landscape', Icons.landscape_outlined, 'https://picsum.photos/seed/g2/300/300'),
    ('Street', Icons.location_city_outlined, 'https://picsum.photos/seed/g3/300/300'),
    ('Wildlife', Icons.pets_outlined, 'https://picsum.photos/seed/g4/300/300'),
    ('Architecture', Icons.apartment_outlined, 'https://picsum.photos/seed/g5/300/300'),
    ('Black & White', Icons.contrast_outlined, 'https://picsum.photos/seed/g6/300/300'),
    ('Macro', Icons.zoom_in_outlined, 'https://picsum.photos/seed/g7/300/300'),
    ('Film', Icons.camera_roll_outlined, 'https://picsum.photos/seed/g8/300/300'),
    ('Night', Icons.nights_stay_outlined, 'https://picsum.photos/seed/g9/300/300'),
    ('Aerial', Icons.flight_outlined, 'https://picsum.photos/seed/g10/300/300'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Glass AppBar + search
          SliverPersistentHeader(
            pinned: true,
            delegate: _ExploreAppBarDelegate(
              searchCtrl: _searchCtrl,
              searching: _searching,
              onFocus: () => setState(() => _searching = true),
              onClear: () => setState(() {
                _searching = false;
                _query = '';
                _searchCtrl.clear();
              }),
              onChanged: (v) => setState(() => _query = v),
              tabCtrl: _tabCtrl,
              tabs: _tabs,
            ),
          ),

          if (!_searching) ...[
            // Genre grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Text('Browse by Genre', style: AppTextStyles.sectionHeader),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _GenreTile(
                    label: _genres[i].$1,
                    icon: _genres[i].$2,
                    imageUrl: _genres[i].$3,
                  ),
                  childCount: _genres.length,
                ),
              ),
            ),

            // Trending tags
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Trending Tags', style: AppTextStyles.sectionHeader),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 36,
                child: ref.watch(trendingTagsProvider).when(
                  data: (tags) {
                    final tagNames = tags.map((t) => t['name'] as String).toList();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: tagNames.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, i) => TagChip(
                        tagName: tagNames[i],
                        onTap: () => context.push('/tag/${tagNames[i]}'),
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 1.5,
                      ),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),

            // Trending now
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Text('Trending Now', style: AppTextStyles.sectionHeader),
                    const SizedBox(width: 8),
                    const Icon(Icons.local_fire_department,
                        color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            ),
            ...ref.watch(photoFeedProvider(page: 0, limit: 18)).when(
              data: (photos) => <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childCount: photos.length,
                    itemBuilder: (context, i) =>
                        _TrendingPhotoTile(photo: photos[i]),
                  ),
                ),
              ],
              loading: () => <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childCount: 9,
                    itemBuilder: (context, i) {
                      final h = [100.0, 130.0, 110.0, 140.0, 100.0, 120.0, 130.0, 110.0, 150.0];
                      return Shimmer.fromColors(
                        baseColor: AppColors.surfaceContainerHigh,
                        highlightColor: AppColors.surfaceContainerHighest,
                        child: Container(
                          height: h[i],
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              error: (_, __) => <Widget>[
                const SliverToBoxAdapter(child: SizedBox.shrink()),
              ],
            ),
          ] else ...[
            // Search results placeholder
            SliverFillRemaining(
              child: _SearchResults(query: _query),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExploreAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchCtrl;
  final bool searching;
  final VoidCallback onFocus;
  final VoidCallback onClear;
  final ValueChanged<String> onChanged;
  final TabController tabCtrl;
  final List<String> tabs;

  const _ExploreAppBarDelegate({
    required this.searchCtrl,
    required this.searching,
    required this.onFocus,
    required this.onClear,
    required this.onChanged,
    required this.tabCtrl,
    required this.tabs,
  });

  @override
  double get minExtent => searching ? 120 : 112;
  @override
  double get maxExtent => searching ? 120 : 112;

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
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: TextField(
                            controller: searchCtrl,
                            onTap: onFocus,
                            onChanged: onChanged,
                            style: AppTextStyles.body,
                            decoration: const InputDecoration(
                              hintText: 'Search photos, people, places...',
                              prefixIcon: Icon(Icons.search,
                                  size: 18,
                                  color: AppColors.onSurfaceVariant),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      if (searching) ...[
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: onClear,
                          child: Text('Cancel',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ],
                  ),
                ),
                // Tabs (only when not searching)
                if (!searching)
                  TabBar(
                    controller: tabCtrl,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.onSurfaceVariant,
                    indicatorColor: AppColors.primary,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: AppTextStyles.exifData,
                    unselectedLabelStyle: AppTextStyles.exifData,
                    dividerColor: Colors.transparent,
                    tabs: tabs.map((t) => Tab(text: t)).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ExploreAppBarDelegate old) =>
      searching != old.searching || searchCtrl.text != old.searchCtrl.text;
}

class _GenreTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String imageUrl;

  const _GenreTile({
    required this.label,
    required this.icon,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xDD000000)],
                stops: [0.3, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text(label,
                    style: AppTextStyles.label.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _TrendingPhotoTile extends StatelessWidget {
  final Map<String, dynamic> photo;
  const _TrendingPhotoTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    final aspectRatios = [1.0, 0.75, 1.25, 0.85, 1.1, 0.9];
    final photoId = photo['id'] as String? ?? '';
    final imageUrl = photo['image_url'] as String? ?? '';
    final photoIndex = photoId.hashCode.abs();
    return GestureDetector(
      onTap: () => context.push('/photo/$photoId'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: AspectRatio(
          aspectRatio: aspectRatios[photoIndex % aspectRatios.length],
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(color: AppColors.surfaceContainerHigh),
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: photoIndex % 300)).fadeIn();
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 40),
            const SizedBox(height: 12),
            Text('Search for photos, people, places',
                style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: 10,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _SearchResultItem(query: query, index: i),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final String query;
  final int index;
  const _SearchResultItem({required this.query, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/photo/search_result_$index'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: 'https://picsum.photos/seed/${query}_$index/100/100',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"$query" shot #${index + 1}', style: AppTextStyles.label),
                Text('by Photographer ${index + 1}',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.onSurfaceVariant, size: 18),
        ],
      ),
    );
  }
}
