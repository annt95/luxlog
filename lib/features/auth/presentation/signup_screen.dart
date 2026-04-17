import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/app/theme.dart';
import 'package:luxlog/core/errors/app_exception.dart';
import 'package:luxlog/features/auth/providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;
    final confirmPassword = _confirmPassCtrl.text;

    // 1. Validate name
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên hiển thị')));
      return;
    }
    if (name.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tên hiển thị quá dài (tối đa 50 ký tự)')));
      return;
    }

    // 2. Validate email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Định dạng email không hợp lệ')));
      return;
    }

    // 3. Validate password strength
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu phải có ít nhất 8 ký tự')));
      return;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu phải chứa ít nhất một chữ hoa')));
      return;
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu phải chứa ít nhất một chữ số')));
      return;
    }

    // 4. Validate confirm password
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu xác nhận không khớp')));
      return;
    }
    
    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signUp(
        email: email,
        password: password,
        displayName: name,
      );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        final message = e is AppException ? e.message : 'Đăng ký không thành công. Vui lòng thử lại.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Positioned.fill(child: _BackgroundCollage()),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(color: Colors.black.withValues(alpha: 0.7)),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Logo().animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      Text('Join Luxlog', style: AppTextStyles.heroTitle.copyWith(fontSize: 32)).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 40),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Create Account', style: AppTextStyles.sectionHeader.copyWith(fontSize: 20)),
                                const SizedBox(height: 24),

                                TextField(
                                  controller: _nameCtrl,
                                  style: AppTextStyles.body,
                                  decoration: const InputDecoration(
                                    labelText: 'Display Name',
                                    prefixIcon: Icon(Icons.person_outline, size: 18),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: AppTextStyles.body,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.mail_outline, size: 18),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _passCtrl,
                                  obscureText: _obscurePass,
                                  style: AppTextStyles.body,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline, size: 18),
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() => _obscurePass = !_obscurePass),
                                      child: Icon(
                                        _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        size: 18,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _confirmPassCtrl,
                                  obscureText: _obscurePass,
                                  style: AppTextStyles.body,
                                  decoration: const InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: Icon(Icons.lock_outline, size: 18),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _signUp,
                                    child: _loading
                                        ? const SizedBox(
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2),
                                          )
                                        : const Text('Sign Up'),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Already have an account? ', style: AppTextStyles.bodySmall),
                                    GestureDetector(
                                      onTap: () => context.pop(),
                                      child: Text('Sign In', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDim],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 24, spreadRadius: 0, offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.camera_alt, color: AppColors.onPrimary, size: 32),
    );
  }
}

class _BackgroundCollage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8),
      itemCount: 12,
      itemBuilder: (context, i) => Image.network('https://picsum.photos/seed/bg_$i/400/500', fit: BoxFit.cover),
    );
  }
}
