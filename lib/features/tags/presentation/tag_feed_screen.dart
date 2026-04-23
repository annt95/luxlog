import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';

/// Screen showing all photos for a specific tag
class TagFeedScreen extends ConsumerWidget {
  final String tagName;

  const TagFeedScreen({super.key, required this.tagName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosByTagProvider(tagName));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: photosAsync.when(
        data: (photos) {
          return CustomScrollView(
            slivers: [
              // Glass AppBar
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xCC0E0E0E),
                foregroundColor: AppColors.onSurface,
                flexibleSpace: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                title: Text('#$tagName', style: AppTextStyles.titleLarge),
              ),

              // Tag stats header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                    border: const Border(
                      left: BorderSide(color: AppColors.primary, width: 3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#$tagName',
                        style: AppTextStyles.heroTitle.copyWith(
                          fontSize: 28,
                          color: AppColors.primary,
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 8),
                      Text(
                        '${photos.length} photos',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Photo Grid
              if (photos.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Text('No photos yet', style: AppTextStyles.body),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: _crossAxisCount(context),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childCount: photos.length,
                    itemBuilder: (context, i) {
                      final photo = photos[i];
                      final id = photo['id'] as String;
                      final url = photo['image_url'] as String? ?? '';
                      final likes = photo['likes_count'] as int? ?? 0;
                      
                      return GestureDetector(
                        onTap: () => context.push('/photo/$id'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: AspectRatio(
                            aspectRatio: [1.0, 0.75, 1.25, 0.85][i % 4],
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: AppColors.surfaceContainerHigh,
                                  ),
                                ),
                                // Like count badge
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          size: 10,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          '$likes',
                                          style: AppTextStyles.caption.copyWith(
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate(delay: Duration(milliseconds: i * 30)).fadeIn();
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(child: Text('Failed to load photos', style: AppTextStyles.body)),
      ),
    );
  }

  int _crossAxisCount(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 1200) return 4;
    if (w > 800) return 3;
    return 2;
  }
}
