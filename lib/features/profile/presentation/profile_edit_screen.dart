import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';

import 'package:luxlog/app/theme.dart';
import 'package:luxlog/features/profile/providers/user_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  bool _isLoading = false;
  Uint8List? _selectedAvatarBytes;
  String? _selectedAvatarExt;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Pre-fill existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentProfile();
    });
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final profile = await ref.read(currentUserProfileProvider.future);
      setState(() {
        _fullNameCtrl.text = profile['full_name'] as String? ?? '';
        _bioCtrl.text = profile['bio'] as String? ?? '';
        _currentAvatarUrl = profile['avatar_url'] as String?;
        final links = profile['links'] as Map<String, dynamic>?;
        if (links != null) {
          _instagramCtrl.text = links['instagram'] as String? ?? '';
          _websiteCtrl.text = links['website'] as String? ?? '';
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data')),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _bioCtrl.dispose();
    _instagramCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      // file size limit: 5MB
      if (bytes.length > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar must be under 5MB')),
        );
        return;
      }
      setState(() {
        _selectedAvatarBytes = bytes;
        final split = file.name.split('.');
        _selectedAvatarExt = split.length > 1 ? split.last : 'jpg';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(userRepositoryProvider);
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      String? avatarUrl = _currentAvatarUrl;

      // 1. Upload avatar if selected
      if (_selectedAvatarBytes != null) {
        // Delete old avatar file from storage if it exists
        if (_currentAvatarUrl != null && _currentAvatarUrl!.contains('/photos/')) {
          try {
            final oldPath = Uri.parse(_currentAvatarUrl!).pathSegments;
            final bucketIdx = oldPath.indexOf('photos');
            if (bucketIdx != -1 && bucketIdx + 1 < oldPath.length) {
              final oldStoragePath = oldPath.sublist(bucketIdx + 1).join('/');
              await client.storage.from('photos').remove([oldStoragePath]);
            }
          } catch (_) {
            // Non-critical: old file cleanup failed, continue with upload
          }
        }

        final path = 'avatars/$userId/${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}.$_selectedAvatarExt';
        
        await client.storage.from('photos').uploadBinary(
              path,
              _selectedAvatarBytes!,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
            );

        avatarUrl = client.storage.from('photos').getPublicUrl(path);
      }

      // 2. Build links JSON
      final links = <String, String>{};
      if (_instagramCtrl.text.trim().isNotEmpty) {
        links['instagram'] = _instagramCtrl.text.trim();
      }
      if (_websiteCtrl.text.trim().isNotEmpty) {
        links['website'] = _websiteCtrl.text.trim();
      }

      // 3. Update profile
      await repo.updateProfile(
        fullName: _fullNameCtrl.text.trim().isNotEmpty ? _fullNameCtrl.text.trim() : null,
        bio: _bioCtrl.text.trim(),
        avatarUrl: avatarUrl,
        links: links,
      );

      // Invalidate current user provider to refresh profile screen
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Edit Profile', style: AppTextStyles.sectionHeader),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section
              GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainerHigh,
                        image: _selectedAvatarBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_selectedAvatarBytes!),
                                fit: BoxFit.cover,
                              )
                            : _currentAvatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_currentAvatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                      ),
                      child: (_selectedAvatarBytes == null &&
                              _currentAvatarUrl == null)
                          ? const Icon(Icons.person, size: 50, color: AppColors.onSurfaceVariant)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: AppColors.background),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Full Name Field
              TextFormField(
                controller: _fullNameCtrl,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'e.g. John Doe',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Bio Field
              TextFormField(
                controller: _bioCtrl,
                style: AppTextStyles.body,
                maxLines: 3,
                maxLength: 160,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  alignLabelWithHint: true,
                  hintText: 'Tell us about your photography...',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Links section
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Links', style: AppTextStyles.sectionHeader.copyWith(fontSize: 16)),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _instagramCtrl,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Instagram Username',
                  prefixText: '@ ',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _websiteCtrl,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Website / Portfolio URL',
                  hintText: 'https://...',
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
