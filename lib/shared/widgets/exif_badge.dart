import 'package:flutter/material.dart';
import 'package:luxlog/app/theme.dart';

/// EXIF metadata badge — Space Grotesk mono font
/// Gold left-accent border, dark background per Stitch design system
class ExifBadge extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ExifBadge({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 2), // Gold accent
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 2),
          ],
          Text(label.toUpperCase(), style: AppTextStyles.exifLabel),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.exifData),
        ],
      ),
    );
  }
}

/// Full EXIF row grid — displayed on photo detail screen
class ExifDataGrid extends StatelessWidget {
  final ExifInfo exif;
  const ExifDataGrid({super.key, required this.exif});

  @override
  Widget build(BuildContext context) {
    final fields = [
      if (exif.camera != null) ('Camera', exif.camera!, Icons.camera_alt_outlined),
      if (exif.lens != null) ('Lens', exif.lens!, Icons.lens_outlined),
      if (exif.iso != null) ('ISO', 'ISO ${exif.iso}', Icons.brightness_6_outlined),
      if (exif.aperture != null) ('Aperture', 'ƒ/${exif.aperture}', Icons.circle_outlined),
      if (exif.shutterSpeed != null) ('Shutter', exif.shutterSpeed!, Icons.shutter_speed),
      if (exif.focalLength != null) ('Focal', '${exif.focalLength}mm', Icons.zoom_in_outlined),
      if (exif.takenAt != null) ('Date', _formatDate(exif.takenAt!), Icons.calendar_today_outlined),
    ];

    if (fields.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fields.map((f) => ExifBadge(
        label: f.$1,
        value: f.$2,
        icon: f.$3,
      )).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}

/// EXIF data model
class ExifInfo {
  final String? camera;
  final String? lens;
  final int? iso;
  final String? aperture;
  final String? shutterSpeed;
  final double? focalLength;
  final DateTime? takenAt;
  final double? latitude;
  final double? longitude;
  final bool? flashUsed;

  const ExifInfo({
    this.camera,
    this.lens,
    this.iso,
    this.aperture,
    this.shutterSpeed,
    this.focalLength,
    this.takenAt,
    this.latitude,
    this.longitude,
    this.flashUsed,
  });

  bool get hasGps => latitude != null && longitude != null;
}
