import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/core/services/image_url_optimizer.dart';

class PhotoCard extends StatefulWidget {
  final String photoId;
  final String imageUrl;
  final String photographerName;
  final String? photographerAvatar;
  final String? title;
  final int likes;
  final bool isLiked;
  final VoidCallback? onLike;
  // EXIF / Film metadata
  final String? camera;
  final String? filmStock;
  final String? lens;

  const PhotoCard({
    super.key,
    required this.photoId,
    required this.imageUrl,
    required this.photographerName,
    this.photographerAvatar,
    this.title,
    required this.likes,
    this.isLiked = false,
    this.onLike,
    this.camera,
    this.filmStock,
    this.lens,
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

  String? get _exifSummary {
    final parts = <String>[];
    if (widget.filmStock != null && widget.filmStock!.isNotEmpty) {
      parts.add(widget.filmStock!);
    }
    if (widget.camera != null && widget.camera!.isNotEmpty) {
      parts.add(widget.camera!);
    } else if (widget.lens != null && widget.lens!.isNotEmpty) {
      parts.add(widget.lens!);
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final optimizedImageUrl = optimizeImageUrl(
      widget.imageUrl,
      width: 1200,
      quality: 76,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => context.push('/photo/${widget.photoId}'),
        child: Semantics(
          label:
              'Photo by ${widget.photographerName}${widget.title != null ? ', ${widget.title}' : ''}',
          hint: 'Tap to open photo details',
          image: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.outlineVariant.withValues(alpha: 0.12),
                width: 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // ── Image ─────────────────────────────────
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: optimizedImageUrl,
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
                                    : Colors.white.withValues(alpha: 0.8),
                                onTap: _toggleLike,
                                isLiked: _liked,
                                likeCount: _likeCount,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      // Photographer avatar
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        backgroundImage: widget.photographerAvatar != null
                            ? CachedNetworkImageProvider(
                                widget.photographerAvatar!)
                            : null,
                        child: widget.photographerAvatar == null
                            ? Text(
                                widget.photographerName.isNotEmpty
                                    ? widget.photographerName[0].toUpperCase()
                                    : '?',
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
                            if (_exifSummary != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  _exifSummary!,
                                  style: AppTextStyles.exifLabel.copyWith(
                                    color: AppColors.primary.withValues(alpha: 0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
  final bool isLiked;
  final int likeCount;

  const _GlassActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isLiked,
    required this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isLiked
          ? 'Unlike photo, current likes $likeCount'
          : 'Like photo, current likes $likeCount',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
