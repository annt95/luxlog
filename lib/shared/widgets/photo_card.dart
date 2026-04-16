import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeshot/app/theme.dart';

class PhotoCard extends StatefulWidget {
  final String photoId;
  final String imageUrl;
  final String photographerName;
  final String? photographerAvatar;
  final String? title;
  final int likes;
  final bool isLiked;
  final double? aspectRatio;
  final VoidCallback? onLike;

  const PhotoCard({
    super.key,
    required this.photoId,
    required this.imageUrl,
    required this.photographerName,
    this.photographerAvatar,
    this.title,
    required this.likes,
    this.isLiked = false,
    this.aspectRatio,
    this.onLike,
  });

  @override
  State<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<PhotoCard> {
  bool _isHovered = false;
  late bool _liked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _liked = widget.isLiked;
    _likeCount = widget.likes;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push('/photo/${widget.photoId}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.outlineVariant.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ─────────────────────────────────
                AspectRatio(
                  aspectRatio: widget.aspectRatio ?? 4 / 3,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: AppColors.surfaceContainerHigh,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      // Glass action overlay on hover
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isHovered ? 1 : 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Color(0xCC000000),
                              ],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: _GlassActionButton(
                                icon: _liked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _liked
                                    ? AppColors.error
                                    : Colors.white.withOpacity(0.8),
                                onTap: _toggleLike,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info row ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      // Photographer avatar
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        backgroundImage: widget.photographerAvatar != null
                            ? CachedNetworkImageProvider(
                                widget.photographerAvatar!)
                            : null,
                        child: widget.photographerAvatar == null
                            ? Text(
                                widget.photographerName[0].toUpperCase(),
                                style: AppTextStyles.exifLabel.copyWith(
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.title != null)
                              Text(
                                widget.title!,
                                style: AppTextStyles.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              widget.photographerName,
                              style: AppTextStyles.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            _liked ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: _liked
                                ? AppColors.error
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatCount(_likeCount),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 300.ms);
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

class _GlassActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GlassActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
