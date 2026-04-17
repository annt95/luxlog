import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luxlog/app/theme.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:luxlog/features/portfolio/presentation/portfolio_editor_screen.dart';
import 'package:luxlog/features/portfolio/providers/portfolio_provider.dart';

class PublicPortfolioScreen extends ConsumerWidget {
  final String slug;
  const PublicPortfolioScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(publicPortfolioProvider(slug));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: portfolioAsync.when(
        data: (blocks) => CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              actions: [
                IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
              ],
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final blockInfo = blocks[index];
                  return _renderBlock(blockInfo);
                },
                childCount: blocks.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Portfolio not found', style: TextStyle(color: AppColors.onSurfaceVariant))),
      ),
    );
  }

  Widget _renderBlock(Map<String, dynamic> block) {
    if (block['type'] == 'hero') return HeroBlock(data: block['data']);
    if (block['type'] == 'text') return TextBlock(data: block['data']);
    if (block['type'] == 'masonry') return MasonryGalleryBlock(data: block['data']);
    return const SizedBox();
  }
}

class HeroBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const HeroBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: data['image_url'],
            fit: BoxFit.cover,
          ),
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
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  style: AppTextStyles.heroTitle.copyWith(fontSize: 48),
                ),
                const SizedBox(height: 8),
                Text(
                  data['subtitle'],
                  style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const TextBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        data['content'],
        style: AppTextStyles.body.copyWith(
          fontSize: 16,
          height: 1.6,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class MasonryGalleryBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const MasonryGalleryBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final images = data['images'] as List;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: MasonryGridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final img = images[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: (img['aspect'] as num).toDouble(),
              child: CachedNetworkImage(
                imageUrl: img['url'],
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
