import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/app/theme.dart';

/// Module 3: Portfolio — dashboard listing all user projects
class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  static const _projects = [
    _Project('Tokyo After Rain', 'Street Documentary · 24 photos',
        'https://picsum.photos/seed/port1/800/500', 2847, true),
    _Project('Faces of Shinjuku', 'Portrait Series · 16 photos',
        'https://picsum.photos/seed/port2/800/500', 1203, true),
    _Project('Neon Nights', 'Urban Nightlife · 32 photos',
        'https://picsum.photos/seed/port3/800/500', 4521, false),
    _Project('Silent Gardens', 'Nature & Zen · 12 photos',
        'https://picsum.photos/seed/port4/800/500', 876, true),
  ];

  @override
  Widget build(BuildContext context) {
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
          SliverToBoxAdapter(child: _PortfolioStats()),

          // New project CTA
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Row(
                children: [
                  Text('My Projects', style: AppTextStyles.sectionHeader),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/portfolio/edit/new'),
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ProjectCard(project: _projects[i], index: i),
              childCount: _projects.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _Project {
  final String title, subtitle, coverUrl;
  final int views;
  final bool isPublic;

  const _Project(
      this.title, this.subtitle, this.coverUrl, this.views, this.isPublic);
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: const [
          _StatItem(value: '847k', label: 'Total Views', icon: Icons.visibility_outlined),
          _Divider(),
          _StatItem(value: '9.3k', label: 'Total Likes', icon: Icons.favorite_border),
          _Divider(),
          _StatItem(value: '4', label: 'Projects', icon: Icons.collections_outlined),
          _Divider(),
          _StatItem(value: '84', label: 'Photos', icon: Icons.photo_outlined),
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
  final _Project project;
  final int index;
  const _ProjectCard({required this.project, required this.index});

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () => context.push('/portfolio/edit/${widget.index}'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withOpacity(0.4)
                    : AppColors.outlineVariant.withOpacity(0.2),
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
                        child: CachedNetworkImage(
                          imageUrl: widget.project.coverUrl,
                          fit: BoxFit.cover,
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
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.project.isPublic
                                    ? Icons.public
                                    : Icons.lock_outline,
                                color: widget.project.isPublic
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.project.isPublic ? 'Public' : 'Draft',
                                style: AppTextStyles.caption.copyWith(
                                  color: widget.project.isPublic
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.project.title,
                                  style: AppTextStyles.titleMedium),
                              const SizedBox(height: 2),
                              Text(widget.project.subtitle,
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Views
                        Row(
                          children: [
                            const Icon(Icons.visibility_outlined,
                                size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              _fmt(widget.project.views),
                              style: AppTextStyles.caption,
                            ),
                          ],
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

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}
