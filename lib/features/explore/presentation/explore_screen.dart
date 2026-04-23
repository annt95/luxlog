import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:luxlog/features/gallery/providers/paginated_feed_notifier.dart';
import 'package:luxlog/features/tags/providers/tag_provider.dart';
import 'package:luxlog/features/explore/data/repositories/category_repository.dart';

/// Explore / Search screen
class ExploreScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  const ExploreScreen({super.key, this.initialQuery});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();
  late final TabController _tabCtrl;
  bool _searching = false;
  String _query = '';
  Timer? _debounce;

  static const _tabs = ['Photos', 'People'];



  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(_onScroll);
    // Restore search query from URL if present
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _query = widget.initialQuery!;
      _searchCtrl.text = _query;
      _searching = true;
    }
  }

  void _onScroll() {
    if (!_searching &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400) {
      ref.read(paginatedDiscoverProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
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
              onChanged: (v) {
                _debounce?.cancel();
                final trimmed = v.length > 200 ? v.substring(0, 200) : v;
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  if (mounted) setState(() => _query = trimmed.trim());
                });
              },
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
            ref.watch(categoriesProvider).when(
              data: (categories) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.4,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final category = categories[i];
                      return _GenreTile(
                        label: category['name'] as String? ?? '',
                        icon: Icons.category_outlined, // Real icons logic if DB stores code
                        imageUrl: category['cover_image'] as String? ?? 'https://picsum.photos/seed/${category['id']}/300/300',
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
              loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
              error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
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
                    final tagNames = tags
                        .map((t) => t['name'] as String?)
                        .whereType<String>()
                        .toList();
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
            ...ref.watch(paginatedDiscoverProvider).when(
              data: (feedState) => <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childCount: feedState.items.length,
                    itemBuilder: (context, i) =>
                        _TrendingPhotoTile(photo: feedState.items[i]),
                  ),
                ),
                if (feedState.hasMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
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
    final tile = GestureDetector(
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
    );
    // Skip heavy per-tile animations on Web to prevent jank
    if (kIsWeb) return tile;
    return tile.animate(delay: Duration(milliseconds: photoIndex % 300)).fadeIn();
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  const _SearchResults({required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    
    return ref.watch(searchPhotosProvider(query)).when(
      data: (photos) {
        if (photos.isEmpty) {
          return Center(
            child: Text('No photos found for "$query"', style: AppTextStyles.body),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: photos.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SearchResultItem(photo: photos[i]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (_, __) => Center(child: Text('Failed to search', style: AppTextStyles.body.copyWith(color: AppColors.error))),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Map<String, dynamic> photo;
  const _SearchResultItem({required this.photo});

  @override
  Widget build(BuildContext context) {
    final photoId = photo['id'] as String? ?? '';
    final title = photo['title'] as String? ?? '';
    final imageUrl = photo['image_url'] as String? ?? '';
    final profile = photo['profiles'] as Map<String, dynamic>?;
    final fullName = profile?['full_name'] as String?;
    final username = profile?['username'] as String? ?? 'User';
    final displayName = (fullName != null && fullName.isNotEmpty) ? fullName : username;

    return GestureDetector(
      onTap: () => context.push('/photo/$photoId'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
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
                Text(title.isNotEmpty ? title : 'Untitled', style: AppTextStyles.label),
                Text('by $displayName',
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
