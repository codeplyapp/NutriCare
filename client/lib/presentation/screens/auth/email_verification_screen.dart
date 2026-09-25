import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';

/// Layar Verifikasi Email (EmailVerificationScreen)
/// Mengadopsi pola 3-Langkah, Auto-detect polling (3.5s), Smart Open Mail App, & Cooldown 60s dari GoLantas / SIGAP
class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String? email;

  const EmailVerificationScreen({super.key, this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  Timer? _pollingTimer;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 60;
  bool _canResend = false;
  bool _isChecking = false;
  bool _isResending = false;
  String? _infoBanner;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
    _startAutoDetectPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    setState(() {
      _cooldownSeconds = 60;
      _canResend = false;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds > 1) {
        setState(() => _cooldownSeconds--);
      } else {
        setState(() {
          _canResend = true;
          _cooldownSeconds = 0;
        });
        timer.cancel();
      }
    });
  }

  void _startAutoDetectPolling() {
    _pollingTimer?.cancel();
    // Auto-detect status verifikasi setiap 3,5 detik
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      _checkVerificationStatus(isAuto: true);
    });
  }

  Future<void> _checkVerificationStatus({bool isAuto = false}) async {
    if (_isChecking) return;
    if (!isAuto) {
      setState(() => _isChecking = true);
    }

    final targetEmail = widget.email ?? ref.read(authProvider).user?.email ?? '';
    final isVerified = await ref
        .read(authProvider.notifier)
        .checkEmailVerification(targetEmail);

    if (!mounted) return;

    if (!isAuto) {
      setState(() => _isChecking = false);
    }

    if (isVerified) {
      _pollingTimer?.cancel();
      _cooldownTimer?.cancel();
      // Navigasi ke onboarding profil gizi bila belum ada profil
      final hasProfile = ref.read(authProvider).hasProfile;
      if (mounted) {
        context.go(hasProfile ? '/dashboard' : '/onboarding-profile');
      }
    } else if (!isAuto) {
      setState(() {
        _infoBanner = 'Email belum terverifikasi. Silakan klik tautan di email Anda terlebih dahulu.';
      });
    }
  }

  Future<void> _handleResendEmail() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
      _infoBanner = null;
    });

    final targetEmail = widget.email ?? ref.read(authProvider).user?.email ?? '';
    final success = await ref
        .read(authProvider.notifier)
        .sendVerificationEmail(targetEmail);

    if (!mounted) return;

    setState(() {
      _isResending = false;
      if (success) {
        _infoBanner = 'Tautan verifikasi baru berhasil dikirimkan ke $targetEmail.';
        _startCooldownTimer();
      } else {
        _infoBanner = 'Gagal mengirim email verifikasi. Silakan coba sesaat lagi.';
      }
    });
  }

  Future<void> _openMailApp() async {
    final email = widget.email ?? ref.read(authProvider).user?.email ?? '';
    final lowerEmail = email.toLowerCase();

    Uri webUrl;
    if (lowerEmail.endsWith('@gmail.com')) {
      webUrl = Uri.parse('https://mail.google.com');
    } else if (lowerEmail.endsWith('@yahoo.com') || lowerEmail.endsWith('@ymail.com')) {
      webUrl = Uri.parse('https://mail.yahoo.com');
    } else if (lowerEmail.endsWith('@outlook.com') || lowerEmail.endsWith('@hotmail.com')) {
      webUrl = Uri.parse('https://outlook.live.com');
    } else {
      final mailtoUri = Uri(scheme: 'mailto');
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
        return;
      }
      webUrl = Uri.parse('https://mail.google.com');
    }

    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayEmail = widget.email ?? ref.watch(authProvider).user?.email ?? 'email Anda';

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
                  // Brand Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Verification Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mascot Waving
                        Center(
                          child: Image.asset(
                            'assets/images/mascot/mascot_waving.png',
                            height: 115,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        Text(
                          'Cek Kotak Masuk Email Anda',
                          textAlign: TextAlign.center,
                          style: AppTypography.display.copyWith(
                            fontSize: 22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Kami telah mengirimkan tautan aktivasi akun ke:\n$displayEmail',
                          textAlign: TextAlign.center,
                          style: AppTypography.body.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Info / Alert Banner
                        if (_infoBanner != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: AppShapes.input,
                              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _infoBanner!,
                                    style: AppTypography.finePrint.copyWith(color: AppColors.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // 3-Step Guide Card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurfaceSecondary,
                            borderRadius: AppShapes.input,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '3 Langkah Mudah Verifikasi:',
                                style: AppTypography.captionStrong.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              _buildStepRow(1, 'Buka aplikasi email Anda.'),
                              _buildStepRow(2, 'Klik tombol/tautan aktivasi NutriCare.'),
                              _buildStepRow(3, 'Akun aktif otomatis, kembali ke aplikasi.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Smart Open Mail Button
                        AppButton(
                          label: 'Buka Aplikasi Email',
                          icon: Icons.open_in_new_rounded,
                          onPressed: _openMailApp,
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // Check Button
                        AppButton(
                          label: 'Sudah Verifikasi — Lanjutkan',
                          variant: AppButtonVariant.secondary,
                          isLoading: _isChecking,
                          onPressed: () => _checkVerificationStatus(isAuto: false),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Resend Cooldown
                        Center(
                          child: _canResend
                              ? TextButton.icon(
                                  onPressed: _isResending ? null : _handleResendEmail,
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: Text(
                                    'Kirim Ulang Email Verifikasi',
                                    style: AppTypography.captionStrong.copyWith(color: AppColors.primary),
                                  ),
                                )
                              : Text(
                                  'Kirim ulang tersedia dalam ${_cooldownSeconds.toString().padLeft(2, '0')} detik',
                                  style: AppTypography.finePrint.copyWith(color: AppColors.textTertiary),
                                ),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Spam Hint Callout
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.06),
                            borderRadius: AppShapes.input,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.help_outline_rounded, color: AppColors.warning, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tidak menemukan email? Cek folder Spam atau Promosi Anda.',
                                  style: AppTypography.finePrint.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Back to login
                        Center(
                          child: TextButton(
                            onPressed: () {
                              ref.read(authProvider.notifier).logout();
                              context.go('/auth');
                            },
                            child: Text(
                              'Ganti Akun / Kembali ke Masuk',
                              style: AppTypography.captionStrong.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildStepRow(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.frozenWater200,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: AppTypography.finePrint.copyWith(
                color: AppColors.frozenWater800,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
