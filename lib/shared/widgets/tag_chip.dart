import 'package:flutter/material.dart';
import 'package:luxlog/app/theme.dart';

/// Tappable tag chip — navigates to tag feed when tapped
class TagChip extends StatelessWidget {
  final String tagName;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showHash;
  final bool isSelected;

  const TagChip({
    super.key,
    required this.tagName,
    this.onTap,
    this.onRemove,
    this.showHash = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(
          left: 10,
          right: onRemove != null ? 4 : 10,
          top: 6,
          bottom: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              showHash ? '#$tagName' : tagName,
              style: AppTextStyles.exifData.copyWith(
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
