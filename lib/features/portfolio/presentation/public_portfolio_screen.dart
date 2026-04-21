import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/error_retry_widget.dart';
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
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    final url = Uri.base.resolve('/p/$slug').toString();
                    Share.share(url);
                  },
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _renderBlock(context, blocks[index]),
                childCount: blocks.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorRetryWidget(
          message: 'Portfolio not found',
          onRetry: () => ref.invalidate(publicPortfolioProvider(slug)),
        ),
      ),
    );
  }

  /// Blocks from the editor use: coverImage, text, photoGrid, divider, contactForm
  Widget _renderBlock(BuildContext context, Map<String, dynamic> block) {
    final type = block['type'] as String? ?? '';
    final content = block['content'] as String? ?? '';

    switch (type) {
      case 'coverImage':
        return _CoverImageBlock(imageUrl: content);
      case 'text':
        return _TextBlock(content: content);
      case 'photoGrid':
        return _PhotoGridBlock(columns: int.tryParse(content) ?? 3);
      case 'divider':
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Divider(color: AppColors.outlineVariant),
        );
      case 'contactForm':
        return const _ContactFormBlock();
      default:
        return const SizedBox();
    }
  }
}

class _CoverImageBlock extends StatelessWidget {
  final String imageUrl;
  const _CoverImageBlock({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        color: AppColors.surfaceContainerHigh,
        child: const Center(child: Icon(Icons.image_outlined, size: 48, color: AppColors.onSurfaceVariant)),
      );
    }
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      margin: const EdgeInsets.only(bottom: 24),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String content;
  const _TextBlock({required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        content,
        style: AppTextStyles.body.copyWith(
          fontSize: 16,
          height: 1.6,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _PhotoGridBlock extends StatelessWidget {
  final int columns;
  const _PhotoGridBlock({required this.columns});

  @override
  Widget build(BuildContext context) {
    // Placeholder — actual photos will be loaded from portfolio_projects or block metadata
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'Photo Grid ($columns columns)',
            style: AppTextStyles.body.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _ContactFormBlock extends StatelessWidget {
  const _ContactFormBlock();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Get in Touch', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Your email',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Message',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
