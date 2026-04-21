import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/error_retry_widget.dart';
import 'package:luxlog/features/portfolio/providers/portfolio_provider.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';

/// Module 3: Portfolio — dashboard listing all user projects
class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.collections_outlined, size: 48, color: AppColors.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('Đăng nhập để quản lý portfolio', style: AppTextStyles.body),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    final portfoliosAsync = ref.watch(userPortfoliosProvider(currentUser.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverPersistentHeader(
            pinned: true,
            delegate: _PortfolioAppBarDelegate(),
          ),

          // Stat cards
          SliverToBoxAdapter(
            child: portfoliosAsync.when(
              data: (portfolios) => _PortfolioStats(portfolios: portfolios),
              loading: () => _PortfolioStats(portfolios: const []),
              error: (_, __) => _PortfolioStats(portfolios: const []),
            ),
          ),

          // New project CTA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Row(
                children: [
                  Text('My Projects', style: AppTextStyles.sectionHeader),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      final repo = ref.read(portfolioRepositoryProvider);
                      final newId = await repo.createPortfolio(currentUser.id, 'Untitled Project');
                      if (context.mounted) context.push('/portfolio/edit/$newId');
                      ref.invalidate(userPortfoliosProvider(currentUser.id));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDim],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add,
                              color: AppColors.onPrimary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'New Project',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600,
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

          // Project list
          portfoliosAsync.when(
            data: (portfolios) => portfolios.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text('Chưa có project nào', style: AppTextStyles.body.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 8),
                            Text('Tạo project đầu tiên để bắt đầu!', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProjectCard(portfolio: portfolios[i], index: i),
                      childCount: portfolios.length,
                    ),
                  ),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: ErrorRetryWidget(
                message: 'Lỗi tải portfolios',
                onRetry: () {
                  final user = ref.read(currentUserProvider);
                  if (user != null) ref.invalidate(userPortfoliosProvider(user.id));
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

// ── AppBar ───────────────────────────────────────────────────────────────────

class _PortfolioAppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 56;
  @override
  double get maxExtent => 64;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Portfolio', style: AppTextStyles.sectionHeader),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined, size: 22),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 22),
                    color: AppColors.onSurfaceVariant,
                    onPressed: () {},
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
  bool shouldRebuild(covariant _PortfolioAppBarDelegate old) => false;
}

// ── Stats ─────────────────────────────────────────────────────────────────────

class _PortfolioStats extends StatelessWidget {
  final List<Map<String, dynamic>> portfolios;
  const _PortfolioStats({required this.portfolios});

  @override
  Widget build(BuildContext context) {
    final projectCount = portfolios.length;
    final publicCount = portfolios.where((p) => p['is_public'] == true).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _StatItem(value: '$projectCount', label: 'Projects', icon: Icons.collections_outlined),
          const _Divider(),
          _StatItem(value: '$publicCount', label: 'Public', icon: Icons.public),
          const _Divider(),
          _StatItem(value: '${projectCount - publicCount}', label: 'Drafts', icon: Icons.edit_outlined),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05);
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.exifData.copyWith(
                fontSize: 16,
                color: AppColors.onSurface,
              )),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 36,
        color: AppColors.outlineVariant,
      );
}

// ── Project Card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatefulWidget {
  final Map<String, dynamic> portfolio;
  final int index;
  const _ProjectCard({required this.portfolio, required this.index});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.portfolio['title'] as String? ?? 'Untitled';
    final isPublic = widget.portfolio['is_public'] as bool? ?? false;
    final coverImage = widget.portfolio['cover_image'] as String?;
    final portfolioId = widget.portfolio['id'] as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => context.push('/portfolio/edit/$portfolioId'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Column(
                children: [
                  // Cover image
                  Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 7,
                        child: coverImage != null
                            ? CachedNetworkImage(
                                imageUrl: coverImage,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: AppColors.surfaceContainerHigh,
                                child: const Center(
                                  child: Icon(Icons.image_outlined, size: 40, color: AppColors.onSurfaceVariant),
                                ),
                              ),
                      ),
                      // Public/Private badge
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPublic ? Icons.public : Icons.lock_outline,
                                color: isPublic
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPublic ? 'Public' : 'Draft',
                                style: AppTextStyles.caption.copyWith(
                                  color: isPublic
                                      ? AppColors.primary
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Info row
                  Container(
                    color: AppColors.surfaceContainerLow,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(title, style: AppTextStyles.titleMedium),
                        ),
                        const SizedBox(width: 12),
                        // Edit btn
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_outlined,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text('Edit',
                                  style: AppTextStyles.exifData
                                      .copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 80))
        .fadeIn()
        .slideY(begin: 0.05);
  }
}
