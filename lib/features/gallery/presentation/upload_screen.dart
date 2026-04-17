import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:exif/exif.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';
import 'package:luxlog/shared/widgets/exif_badge.dart';
import 'package:luxlog/shared/widgets/tag_input_widget.dart';
import 'package:luxlog/shared/widgets/tag_chip.dart';
import 'package:luxlog/features/gallery/providers/photo_provider.dart';
import 'package:luxlog/features/tags/providers/category_provider.dart';
import 'package:luxlog/features/tags/providers/tag_provider.dart';

/// Upload screen — image picker + EXIF parse + preview + Film Mode
class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  ExifInfo? _parsedExif;
  bool _parsingExif = false;
  int _currentStep = 0; // 0: pick, 1: details, 2: uploading
  String? _errorMessage;

  final _captionCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _filmCameraCtrl = TextEditingController();
  final _filmStockCtrl = TextEditingController();
  List<String> _tags = [];
  List<String> _selectedCategories = []; // category IDs
  bool _shareGps = false;
  bool _allowDownload = true;
  bool _isFilm = false;
  String _selectedLicense = 'CC BY 4.0';

  static const _licenses = ['CC BY 4.0', 'CC BY-SA 4.0', 'CC BY-NC 4.0', 'All Rights Reserved'];

  static const int _maxFileSizeBytes = 20 * 1024 * 1024; // 20MB

  @override
  void dispose() {
    _captionCtrl.dispose();
    _titleCtrl.dispose();
    _filmCameraCtrl.dispose();
    _filmStockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 100);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    // File size validation
    if (bytes.length > _maxFileSizeBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File size exceeds 20MB limit. Please choose a smaller image.'),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedImage = picked;
      _selectedImageBytes = bytes;
      _parsedExif = null;
      _parsingExif = true;
      _errorMessage = null;
    });

    // Parse EXIF
    try {
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
    // Validate required fields
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title for your photo')),
      );
      return;
    }
    if (_titleCtrl.text.trim().length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title must be under 200 characters')),
      );
      return;
    }
    if (_captionCtrl.text.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caption must be under 2000 characters')),
      );
      return;
    }
    if (_tags.length > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 30 tags allowed')),
      );
      return;
    }

    setState(() {
      _currentStep = 2;
      _errorMessage = null;
    });

    try {
      final photoId = await ref.read(photoRepositoryProvider).uploadPhoto(
        fileBytes: _selectedImageBytes!,
        fileName: _selectedImage!.name,
        title: _titleCtrl.text.trim(),
        caption: _captionCtrl.text.trim(),
        license: _selectedLicense,
        allowDownload: _allowDownload,
        isFilm: _isFilm,
        filmStock: _isFilm ? _filmStockCtrl.text.trim() : null,
        filmCamera: _isFilm ? _filmCameraCtrl.text.trim() : null,
        camera: _parsedExif?.camera,
        lens: _parsedExif?.lens,
        iso: _parsedExif?.iso,
        aperture: _parsedExif?.aperture,
        shutterSpeed: _parsedExif?.shutterSpeed,
        focalLength: _parsedExif?.focalLength,
        latitude: _parsedExif?.latitude,
        longitude: _parsedExif?.longitude,
        shareGps: _shareGps,
      );

      if (_tags.isNotEmpty) {
        await ref.read(tagRepositoryProvider).attachTagsToPhoto(photoId, _tags);
      }
      if (_selectedCategories.isNotEmpty) {
        await ref
            .read(categoryRepositoryProvider)
            .attachCategoriesToPhoto(photoId, _selectedCategories);
      }

      // Invalidate feed so new photo appears
      ref.invalidate(photoFeedProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      final message = e is AppException
          ? e.message
          : 'Upload failed. Please try again.';
      if (mounted) {
        setState(() {
          _currentStep = 1;
          _errorMessage = message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.errorContainer,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const [];
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _currentStep == 0
            ? _PickStep(onPick: _pickImage)
            : _currentStep == 1
                ? _DetailsStep(
                    imageBytes: _selectedImageBytes!,
                    exif: _parsedExif,
                    parsingExif: _parsingExif,
                    captionCtrl: _captionCtrl,
                    titleCtrl: _titleCtrl,
                    tags: _tags,
                    selectedCategories: _selectedCategories,
                    categories: categories,
                    onTagsChanged: (tags) => setState(() => _tags = tags),
                    onCategoryToggled: (categoryId) => setState(() {
                      if (_selectedCategories.contains(categoryId)) {
                        _selectedCategories.remove(categoryId);
                      } else {
                        _selectedCategories.add(categoryId);
                      }
                    }),
                    onSuggestCategory: (name) async {
                      final userId = currentUser?.id;
                      if (userId == null) {
                        throw const AuthException(
                          'Bạn cần đăng nhập để đề xuất danh mục',
                        );
                      }
                      await ref.read(categoryRepositoryProvider).suggestCategory(
                            name: name,
                            userId: userId,
                          );
                      ref.invalidate(categoriesProvider);
                    },
                    onSearchTags: (query) async {
                      final results =
                          await ref.read(tagRepositoryProvider).searchTags(query);
                      return results
                          .map((tag) => tag['name'] as String)
                          .toList();
                    },
                    shareGps: _shareGps,
                    allowDownload: _allowDownload,
                    license: _selectedLicense,
                    licenses: _licenses,
                    onShareGpsChanged: (v) => setState(() => _shareGps = v),
                    onDownloadChanged: (v) => setState(() => _allowDownload = v),
                    onLicenseChanged: (v) => setState(() => _selectedLicense = v!),
                    onBack: () => setState(() => _currentStep = 0),
                    onUpload: _upload,
                    isFilm: _isFilm,
                    onFilmChanged: (v) => setState(() => _isFilm = v),
                    filmCameraCtrl: _filmCameraCtrl,
                    filmStockCtrl: _filmStockCtrl,
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
  final Uint8List imageBytes;
  final ExifInfo? exif;
  final bool parsingExif;
  final TextEditingController captionCtrl;
  final TextEditingController titleCtrl;
  final List<String> tags;
  final List<String> selectedCategories;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<List<String>> onTagsChanged;
  final ValueChanged<String> onCategoryToggled;
  final Future<void> Function(String name) onSuggestCategory;
  final Future<List<String>> Function(String query) onSearchTags;
  final bool shareGps;
  final bool allowDownload;
  final String license;
  final List<String> licenses;
  final ValueChanged<bool> onShareGpsChanged;
  final ValueChanged<bool> onDownloadChanged;
  final ValueChanged<String?> onLicenseChanged;
  final VoidCallback onBack;
  final VoidCallback onUpload;
  final bool isFilm;
  final ValueChanged<bool> onFilmChanged;
  final TextEditingController filmCameraCtrl;
  final TextEditingController filmStockCtrl;

  const _DetailsStep({
    required this.imageBytes,
    required this.exif,
    required this.parsingExif,
    required this.captionCtrl,
    required this.titleCtrl,
    required this.tags,
    required this.selectedCategories,
    required this.categories,
    required this.onTagsChanged,
    required this.onCategoryToggled,
    required this.onSuggestCategory,
    required this.onSearchTags,
    required this.shareGps,
    required this.allowDownload,
    required this.license,
    required this.licenses,
    required this.onShareGpsChanged,
    required this.onDownloadChanged,
    required this.onLicenseChanged,
    required this.onBack,
    required this.onUpload,
    required this.isFilm,
    required this.onFilmChanged,
    required this.filmCameraCtrl,
    required this.filmStockCtrl,
  });

  void _showSuggestDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text('Suggest a Category', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggest a new category for the community. It will be reviewed before appearing publicly.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'e.g. Astrophotography',
                prefixIcon: Icon(Icons.category_outlined, size: 18, color: AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isNotEmpty) {
                try {
                  await onSuggestCategory(nameCtrl.text.trim());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Category "${nameCtrl.text.trim()}" suggested!',
                        ),
                        backgroundColor: AppColors.primaryContainer,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } on AppException catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.message),
                        backgroundColor: AppColors.errorContainer,
                      ),
                    );
                  }
                }
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

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
                      child: Image.memory(
                        imageBytes,
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

                // Tags — chip-based input
                _SectionLabel('Tags'),
                const SizedBox(height: 8),
                TagInputWidget(
                  tags: tags,
                  onTagsChanged: onTagsChanged,
                  onSearch: onSearchTags,
                ),

                const SizedBox(height: 20),

                // Category picker
                _SectionLabel('Category'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...categories.map((cat) {
                      final categoryId = cat['id'] as String;
                      final categoryName = cat['name'] as String? ?? 'Unknown';
                      final isSelected = selectedCategories.contains(categoryId);
                      return TagChip(
                        tagName: categoryName,
                        showHash: false,
                        isSelected: isSelected,
                        onTap: () => onCategoryToggled(categoryId),
                      );
                    }),
                    // Suggest new category button
                    GestureDetector(
                      onTap: () => _showSuggestDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Suggest new...',
                              style: AppTextStyles.exifData.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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

                // Film Mode Toggle
                _ToggleRow(
                  icon: Icons.camera_roll_outlined,
                  title: 'Shot on Film',
                  subtitle: 'Manually enter camera and film stock info',
                  value: isFilm,
                  onChanged: onFilmChanged,
                ),

                if (isFilm) ...[
                  const SizedBox(height: 16),
                  _SectionLabel('Film Details'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: filmCameraCtrl,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      labelText: 'Film Camera',
                      hintText: 'e.g. Contax G2',
                      prefixIcon: Icon(Icons.camera_alt_outlined, size: 18),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: filmStockCtrl,
                    style: AppTextStyles.body,
                    decoration: const InputDecoration(
                      labelText: 'Film Stock',
                      hintText: 'e.g. Kodak Portra 400',
                      prefixIcon: Icon(Icons.camera_roll_outlined, size: 18),
                    ),
                  ),
                ],

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
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
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
