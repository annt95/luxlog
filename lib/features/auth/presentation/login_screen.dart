import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:vibeshot/app/theme.dart';

/// Auth: Login Screen — Darkroom editorial style
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Background photo collage
          Positioned.fill(child: _BackgroundCollage()),

          // Dark overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      _Logo().animate().scale(
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                      const SizedBox(height: 16),

                      Text('VibeShot', style: AppTextStyles.heroTitle.copyWith(fontSize: 36))
                          .animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 6),
                      Text(
                        'Where photographers connect',
                        style: AppTextStyles.body.copyWith(color: AppColors.onSurfaceVariant),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 40),

                      // Glass card
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
                                Text('Sign In', style: AppTextStyles.sectionHeader.copyWith(fontSize: 20)),
                                const SizedBox(height: 24),

                                // Social login buttons
                                _SocialButton(
                                  icon: Icons.g_mobiledata_rounded,
                                  label: 'Continue with Google',
                                  onTap: _signIn,
                                ),
                                const SizedBox(height: 10),
                                _SocialButton(
                                  icon: Icons.apple,
                                  label: 'Continue with Apple',
                                  onTap: _signIn,
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Row(
                                    children: [
                                      Expanded(child: Container(height: 1, color: AppColors.outlineVariant)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text('or', style: AppTextStyles.caption),
                                      ),
                                      Expanded(child: Container(height: 1, color: AppColors.outlineVariant)),
                                    ],
                                  ),
                                ),

                                // Email field
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

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text('Forgot password?', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
                                  ),
                                ),

                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _signIn,
                                    child: _loading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: AppColors.onPrimary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Sign In'),
                                  ),
                                ),

                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Don't have an account? ", style: AppTextStyles.bodySmall),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text('Join VibeShot', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.camera_alt, color: AppColors.onPrimary, size: 32),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.onSurface),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}

class _BackgroundCollage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
      ),
      itemCount: 12,
      itemBuilder: (context, i) => Image.network(
        'https://picsum.photos/seed/bg_$i/400/500',
        fit: BoxFit.cover,
      ),
    );
  }
}
