import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:luxlog/app/theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
    // Validate password
    if (_passCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    // TODO: Call auth repository
    if (mounted) context.go('/');
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
              child: Container(color: Colors.black.withOpacity(0.7)),
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
            color: AppColors.primary.withOpacity(0.4),
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
