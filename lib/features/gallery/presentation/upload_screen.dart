import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'dart:io';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/shared/widgets/exif_badge.dart';

/// Upload screen — image picker + EXIF parse + preview
class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  ExifInfo? _parsedExif;
  bool _parsingExif = false;
  bool _uploading = false;
  int _currentStep = 0; // 0: pick, 1: details, 2: uploading

  final _captionCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  bool _shareGps = false;
  bool _allowDownload = true;
  String _selectedLicense = 'CC BY 4.0';

  static const _licenses = ['CC BY 4.0', 'CC BY-SA 4.0', 'CC BY-NC 4.0', 'All Rights Reserved'];

  @override
  void dispose() {
    _captionCtrl.dispose();
    _titleCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 100);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _selectedImage = file;
      _parsedExif = null;
      _parsingExif = true;
    });

    // Parse EXIF
    try {
      final bytes = await file.readAsBytes();
      final tags = await readExifFromBytes(bytes);

      ExifInfo? info;
      if (tags.isNotEmpty) {
        info = ExifInfo(
          camera: _exifString(tags, 'Image Make') != null && _exifString(tags, 'Image Model') != null
              ? '${_exifString(tags, 'Image Make')} ${_exifString(tags, 'Image Model')}'
              : _exifString(tags, 'Image Model'),
          lens: _exifString(tags, 'EXIF LensModel'),
          iso: _exifInt(tags, 'EXIF ISOSpeedRatings'),
          aperture: _exifRational(tags, 'EXIF FNumber'),
          shutterSpeed: _exifString(tags, 'EXIF ExposureTime'),
          focalLength: _exifRationalDouble(tags, 'EXIF FocalLength'),
          takenAt: _parseDate(tags['EXIF DateTimeOriginal']?.toString()),
          latitude: _parseGps(tags, 'GPS GPSLatitude', tags['GPS GPSLatitudeRef']?.toString()),
          longitude: _parseGps(tags, 'GPS GPSLongitude', tags['GPS GPSLongitudeRef']?.toString()),
        );
      }

      setState(() {
        _parsedExif = info;
        _parsingExif = false;
        _currentStep = 1;
      });
    } catch (e) {
      setState(() {
        _parsedExif = null;
        _parsingExif = false;
        _currentStep = 1;
      });
    }
  }

  String? _exifString(Map<String, IfdTag> tags, String key) {
    final val = tags[key]?.printable;
    if (val == null || val.isEmpty || val == 'None') return null;
    return val.trim();
  }

  int? _exifInt(Map<String, IfdTag> tags, String key) {
    final val = tags[key]?.printable;
    if (val == null) return null;
    return int.tryParse(val.replaceAll(RegExp(r'[^\d]'), ''));
  }

  String? _exifRational(Map<String, IfdTag> tags, String key) {
    final val = tags[key];
    if (val == null) return null;
    final parts = val.printable.split('/');
    if (parts.length == 2) {
      final num = double.tryParse(parts[0]);
      final den = double.tryParse(parts[1]);
      if (num != null && den != null && den != 0) {
        return (num / den).toStringAsFixed(1);
      }
    }
    return val.printable;
  }

  double? _exifRationalDouble(Map<String, IfdTag> tags, String key) {
    final str = _exifRational(tags, key);
    return str != null ? double.tryParse(str) : null;
  }

  DateTime? _parseDate(String? str) {
    if (str == null || str.isEmpty) return null;
    try {
      final parts = str.replaceAll(':', '-').split(' ');
      return DateTime.parse('${parts[0]}T${parts[1].replaceAll('-', ':')}');
    } catch (_) {
      return null;
    }
  }

  double? _parseGps(Map<String, IfdTag> tags, String key, String? ref) {
    final val = tags[key];
    if (val == null) return null;
    try {
      final parts = val.printable.replaceAll('[', '').replaceAll(']', '').split(', ');
      if (parts.length != 3) return null;
      double deg = _parseFraction(parts[0]);
      double min = _parseFraction(parts[1]);
      double sec = _parseFraction(parts[2]);
      double result = deg + min / 60 + sec / 3600;
      if (ref == 'S' || ref == 'W') result = -result;
      return result;
    } catch (_) {
      return null;
    }
  }

  double _parseFraction(String s) {
    final parts = s.split('/');
    if (parts.length == 2) {
      return double.parse(parts[0]) / double.parse(parts[1]);
    }
    return double.parse(s);
  }

  Future<void> _upload() async {
    setState(() {
      _uploading = true;
      _currentStep = 2;
    });
    // TODO: Supabase upload
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _currentStep == 0
            ? _PickStep(onPick: _pickImage)
            : _currentStep == 1
                ? _DetailsStep(
                    image: _selectedImage!,
                    exif: _parsedExif,
                    parsingExif: _parsingExif,
                    captionCtrl: _captionCtrl,
                    titleCtrl: _titleCtrl,
                    tagsCtrl: _tagsCtrl,
                    shareGps: _shareGps,
                    allowDownload: _allowDownload,
                    license: _selectedLicense,
                    licenses: _licenses,
                    onShareGpsChanged: (v) => setState(() => _shareGps = v),
                    onDownloadChanged: (v) => setState(() => _allowDownload = v),
                    onLicenseChanged: (v) => setState(() => _selectedLicense = v!),
                    onBack: () => setState(() => _currentStep = 0),
                    onUpload: _upload,
                  )
                : const _UploadingStep(),
      ),
    );
  }
}

// ── Step 0: Pick image ────────────────────────────────────────────────────────

class _PickStep extends StatelessWidget {
  final void Function(ImageSource) onPick;
  const _PickStep({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: AppColors.onSurface, size: 24),
              ),
              const SizedBox(width: 16),
              Text('New Post', style: AppTextStyles.titleLarge),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.surfaceContainerHigh),

        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Camera icon placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.outlineVariant,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ).animate().scale(duration: 300.ms, curve: Curves.easeOut),

                const SizedBox(height: 24),
                Text(
                  'Select a photo to share',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'EXIF data will be automatically read',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 40),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _PickButton(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () => onPick(ImageSource.gallery),
                    ),
                    const SizedBox(width: 16),
                    _PickButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () => onPick(ImageSource.camera),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.label.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}

// ── Step 1: Details + EXIF ───────────────────────────────────────────────────

class _DetailsStep extends StatelessWidget {
  final File image;
  final ExifInfo? exif;
  final bool parsingExif;
  final TextEditingController captionCtrl;
  final TextEditingController titleCtrl;
  final TextEditingController tagsCtrl;
  final bool shareGps;
  final bool allowDownload;
  final String license;
  final List<String> licenses;
  final ValueChanged<bool> onShareGpsChanged;
  final ValueChanged<bool> onDownloadChanged;
  final ValueChanged<String?> onLicenseChanged;
  final VoidCallback onBack;
  final VoidCallback onUpload;

  const _DetailsStep({
    required this.image,
    required this.exif,
    required this.parsingExif,
    required this.captionCtrl,
    required this.titleCtrl,
    required this.tagsCtrl,
    required this.shareGps,
    required this.allowDownload,
    required this.license,
    required this.licenses,
    required this.onShareGpsChanged,
    required this.onDownloadChanged,
    required this.onLicenseChanged,
    required this.onBack,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 22),
              ),
              const SizedBox(width: 16),
              Text('Post Details', style: AppTextStyles.titleLarge),
              const Spacer(),
              ElevatedButton(
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text('Share'),
              ),
            ],
          ),
        ),
        Container(height: 1, color: AppColors.surfaceContainerHigh),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview + caption row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.file(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: captionCtrl,
                        maxLines: 4,
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText: 'Write a caption...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),

                Container(height: 1, color: AppColors.surfaceContainerHigh, margin: const EdgeInsets.symmetric(vertical: 16)),

                // Title
                _SectionLabel('Photo Title'),
                const SizedBox(height: 8),
                TextField(
                  controller: titleCtrl,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Give your photo a title...',
                  ),
                ),

                const SizedBox(height: 16),

                // Tags
                _SectionLabel('Tags'),
                const SizedBox(height: 8),
                TextField(
                  controller: tagsCtrl,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'landscape, golden hour, sony...',
                    prefixIcon: Icon(Icons.tag, size: 18, color: AppColors.onSurfaceVariant),
                  ),
                ),

                const SizedBox(height: 20),

                // EXIF section
                _SectionLabel('Camera Data (EXIF)'),
                const SizedBox(height: 12),
                if (parsingExif)
                  Row(children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 1.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Reading EXIF data...', style: AppTextStyles.bodySmall),
                  ])
                else if (exif != null)
                  _ExifPreview(exif: exif!)
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('No EXIF data found', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Privacy / GPS
                if (exif?.hasGps == true) ...[
                  _ToggleRow(
                    icon: Icons.location_on_outlined,
                    title: 'Share location',
                    subtitle: 'Show GPS coordinates on your photo',
                    value: shareGps,
                    onChanged: onShareGpsChanged,
                    isWarning: true,
                  ),
                  const SizedBox(height: 12),
                ],

                _ToggleRow(
                  icon: Icons.download_outlined,
                  title: 'Allow downloads',
                  subtitle: 'Others can download original file',
                  value: allowDownload,
                  onChanged: onDownloadChanged,
                ),

                const SizedBox(height: 16),

                // License
                _SectionLabel('License'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: DropdownButton<String>(
                    value: license,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.surfaceContainerHigh,
                    style: AppTextStyles.body,
                    items: licenses.map((l) => DropdownMenuItem(
                      value: l,
                      child: Text(l),
                    )).toList(),
                    onChanged: onLicenseChanged,
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 2, height: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(text.toUpperCase(), style: AppTextStyles.exifLabel.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.2,
        )),
      ],
    );
  }
}

class _ExifPreview extends StatelessWidget {
  final ExifInfo exif;
  const _ExifPreview({required this.exif});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (exif.camera != null)
          _ExifChip(label: 'Camera', value: exif.camera!),
        if (exif.lens != null)
          _ExifChip(label: 'Lens', value: exif.lens!),
        if (exif.iso != null)
          _ExifChip(label: 'ISO', value: 'ISO ${exif.iso}'),
        if (exif.aperture != null)
          _ExifChip(label: 'Aperture', value: 'ƒ/${exif.aperture}'),
        if (exif.shutterSpeed != null)
          _ExifChip(label: 'Shutter', value: exif.shutterSpeed!),
        if (exif.focalLength != null)
          _ExifChip(label: 'Focal', value: '${exif.focalLength}mm'),
        if (exif.hasGps)
          _ExifChip(label: 'GPS', value: 'Detected'),
      ],
    );
  }
}

class _ExifChip extends StatelessWidget {
  final String label;
  final String value;
  const _ExifChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.exifLabel),
          Text(value, style: AppTextStyles.exifData),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isWarning;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        border: isWarning && value
            ? Border.all(color: AppColors.error.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: isWarning && value
                  ? AppColors.error
                  : AppColors.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isWarning ? AppColors.error : AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Uploading ─────────────────────────────────────────────────────────

class _UploadingStep extends StatelessWidget {
  const _UploadingStep();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
          const SizedBox(height: 24),
          Text('Uploading your photo...', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text('Processing EXIF metadata', style: AppTextStyles.bodySmall),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
