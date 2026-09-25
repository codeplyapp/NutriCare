import 'dart:async';
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

/// Layar Verifikasi Ulang (ReverifyScreen)
/// Mengadopsi pola penanganan akun belum aktif dari GoLantas / SIGAP
class ReverifyScreen extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ReverifyScreen({super.key, this.initialEmail});

  @override
  ConsumerState<ReverifyScreen> createState() => _ReverifyScreenState();
}

class _ReverifyScreenState extends ConsumerState<ReverifyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds > 1) {
        setState(() => _cooldownSeconds--);
      } else {
        setState(() => _cooldownSeconds = 0);
        timer.cancel();
      }
    });
  }

  Future<void> _handleSendVerification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cooldownSeconds > 0 || _isLoading) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _isSuccess = false;
    });

    final email = _emailController.text.trim();
    try {
      final success = await ref
          .read(authProvider.notifier)
          .sendVerificationEmail(email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (success) {
          _isSuccess = true;
          _statusMessage = 'Tautan verifikasi baru berhasil dikirim ke $email.';
          _startCooldown();
        } else {
          _isSuccess = false;
          _statusMessage = 'Gagal mengirim email verifikasi. Pastikan email terdaftar.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _statusMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Icon
                          Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mark_email_unread_outlined,
                                color: AppColors.warning,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Text(
                            'Kirim Ulang Verifikasi Email',
                            textAlign: TextAlign.center,
                            style: AppTypography.display.copyWith(
                              fontSize: 20,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Akun Anda belum aktif. Masukkan email terdaftar untuk menerima tautan aktivasi baru.',
                            textAlign: TextAlign.center,
                            style: AppTypography.body.copyWith(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Status banner
                          if (_statusMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: _isSuccess
                                    ? AppColors.frozenWater100
                                    : AppColors.error.withOpacity(0.08),
                                borderRadius: AppShapes.input,
                                border: Border.all(
                                  color: _isSuccess
                                      ? AppColors.frozenWater600
                                      : AppColors.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                                    color: _isSuccess ? AppColors.frozenWater800 : AppColors.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _statusMessage!,
                                      style: AppTypography.finePrint.copyWith(
                                        color: _isSuccess ? AppColors.frozenWater900 : AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

                          AppTextField(
                            label: 'Email Terdaftar',
                            hint: 'nama@domain.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                              if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          AppButton(
                            label: _cooldownSeconds > 0
                                ? 'Tunggu ${_cooldownSeconds}s'
                                : 'Kirim Tautan Verifikasi',
                            isLoading: _isLoading,
                            onPressed: _cooldownSeconds > 0 ? null : _handleSendVerification,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          if (_isSuccess) ...[
                            AppButton(
                              label: 'Menuju Layar Verifikasi',
                              variant: AppButtonVariant.secondary,
                              onPressed: () {
                                context.go(
                                  '/email-verification?email=${Uri.encodeComponent(_emailController.text.trim())}',
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],

                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/auth'),
                              child: Text(
                                'Kembali ke Halaman Masuk',
                                style: AppTypography.captionStrong.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
