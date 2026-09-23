import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'budi@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (success && mounted) {
        final authState = ref.read(authProvider);
        if (authState.hasProfile) {
          context.go('/dashboard');
        } else {
          context.go('/onboarding-profile');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppShapes.input,
                        ),
                        child: const Icon(Icons.favorite_rounded, color: AppColors.onPrimary, size: 32),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'NutriCare',
                      textAlign: TextAlign.center,
                      style: AppTypography.display.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Kecerdasan Gizi Personal & Pemantauan Sehat Harian',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Login Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Masuk ke Akun Anda', style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary, fontSize: 16)),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Email',
                            hint: 'nama@domain.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (v) => v == null || !v.contains('@') ? 'Masukkan email valid' : null,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Kata Sandi',
                            hint: '••••••••',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
                            validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (authState.errorMessage != null) ...[
                            Text(
                              authState.errorMessage!,
                              style: AppTypography.captionStrong.copyWith(color: AppColors.error),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          AppButton(
                            text: 'Masuk Sekarang',
                            isLoading: authState.isLoading,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Switch to Register
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Belum memiliki akun? ', style: AppTypography.body.copyWith(fontSize: 14, color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => context.go('/register'),
                          child: Text(
                            'Daftar di sini',
                            style: AppTypography.captionStrong.copyWith(
                              fontSize: 14,
                              color: AppColors.primaryHover,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
