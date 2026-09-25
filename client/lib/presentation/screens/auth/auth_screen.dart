import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/core/utils/password_policy.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';
import 'package:nutricare/presentation/screens/auth/forgot_password_sheet.dart';
import 'package:nutricare/presentation/widgets/app_button.dart';
import 'package:nutricare/presentation/widgets/app_card.dart';
import 'package:nutricare/presentation/widgets/app_text_field.dart';
import 'package:nutricare/presentation/widgets/password_strength_meter.dart';

/// Layar Autentikasi NutriCare (AuthScreen)
/// Mengadopsi pola Satu Kartu dengan Tab Toggle (Masuk & Daftar) dari GoLantas / SIGAP
class AuthScreen extends ConsumerStatefulWidget {
  final int initialTabIndex; // 0: Masuk, 1: Daftar

  const AuthScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _obscureLoginPassword = true;

  // Register Controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regConfirmPasswordController = TextEditingController();
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;
  bool _consentPDP = false;

  PasswordValidationResult _passwordResult = PasswordPolicy.evaluate('');
  Timer? _lockoutTicker;
  int _lockoutSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _regPasswordController.addListener(_onPasswordChanged);
    _regNameController.addListener(_onRegisterDraftChanged);
    _regEmailController.addListener(_onRegisterDraftChanged);

    _loadRegisterDraft();
    _initLockoutTicker();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regConfirmPasswordController.dispose();
    _lockoutTicker?.cancel();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordResult = PasswordPolicy.evaluate(_regPasswordController.text);
    });
  }

  void _onRegisterDraftChanged() {
    final name = _regNameController.text;
    final email = _regEmailController.text;
    if (name.isNotEmpty || email.isNotEmpty) {
      ref.read(authProvider.notifier).saveRegisterDraft(name, email);
    }
  }

  Future<void> _loadRegisterDraft() async {
    final draft = await ref.read(authProvider.notifier).getRegisterDraft();
    if (draft != null && mounted) {
      if (_regNameController.text.isEmpty && draft['name'] != null) {
        _regNameController.text = draft['name']!;
      }
      if (_regEmailController.text.isEmpty && draft['email'] != null) {
        _regEmailController.text = draft['email']!;
      }
    }
  }

  void _initLockoutTicker() {
    _lockoutTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      final authState = ref.read(authProvider);
      if (authState.isLockedOut) {
        if (mounted) {
          setState(() {
            _lockoutSecondsLeft = authState.remainingLockoutSeconds;
          });
        }
      } else if (_lockoutSecondsLeft > 0) {
        if (mounted) {
          setState(() {
            _lockoutSecondsLeft = 0;
          });
        }
      }
    });
  }

  String _formatLockoutTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _handleLogin() async {
    if (ref.read(authProvider).isLockedOut) return;
    if (!_loginFormKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          _loginEmailController.text.trim(),
          _loginPasswordController.text,
        );

    if (success && mounted) {
      final authState = ref.read(authProvider);
      if (!authState.isEmailVerified) {
        context.go(
          '/email-verification?email=${Uri.encodeComponent(_loginEmailController.text.trim())}',
        );
      } else {
        context.go(authState.hasProfile ? '/dashboard' : '/onboarding-profile');
      }
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    if (!_passwordResult.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi harus memenuhi minimal 4 dari 5 kriteria keamanan.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_consentPDP) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda wajib menyetujui persetujuan pemrosesan data UU PDP.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final email = _regEmailController.text.trim();
    final success = await ref.read(authProvider.notifier).register(
          name: _regNameController.text.trim(),
          email: email,
          password: _regPasswordController.text,
          consent: _consentPDP,
        );

    if (success && mounted) {
      context.go('/email-verification?email=${Uri.encodeComponent(email)}');
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success = await ref.read(authProvider.notifier).loginWithGoogle();
    if (success && mounted) {
      final authState = ref.read(authProvider);
      context.go(authState.hasProfile ? '/dashboard' : '/onboarding-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLockedOut = authState.isLockedOut || _lockoutSecondsLeft > 0;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Official Brand Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Kecerdasan Gizi Personal & Pemantauan Sehat Harian',
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Single Unified Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Segmented Tab Toggle (Apple/GoLantas Style)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.bgSurfaceSecondary,
                            borderRadius: AppShapes.input,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: AppColors.bgSurface,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: AppColors.textSecondary,
                            labelStyle: AppTypography.captionStrong.copyWith(fontSize: 14),
                            unselectedLabelStyle: AppTypography.captionStrong.copyWith(fontSize: 14),
                            tabs: const [
                              Tab(text: 'Masuk'),
                              Tab(text: 'Daftar Akun'),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Error Banner (if any)
                        if (authState.errorMessage != null && !isLockedOut) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: AppShapes.input,
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: AppTypography.finePrint.copyWith(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        // Tab Contents
                        if (_tabController.index == 0)
                          _buildLoginTab(authState, isLockedOut)
                        else
                          _buildRegisterTab(authState),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  // Footer Disclaimer UU PDP
                  Text(
                    'Dilindungi dengan enkripsi standar medis & patuh UU No. 27/2022 (UU PDP).',
                    textAlign: TextAlign.center,
                    style: AppTypography.finePrint.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 11,
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

  Widget _buildLoginTab(AuthState authState, bool isLockedOut) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lockout Banner with live countdown
          if (isLockedOut) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: AppShapes.input,
                border: Border.all(color: AppColors.error.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_clock_rounded, color: AppColors.error, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    'Akun Dikunci Sementara',
                    style: AppTypography.captionStrong.copyWith(
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Terlalu banyak percobaan masuk yang salah (5x). Silakan coba lagi dalam:',
                    textAlign: TextAlign.center,
                    style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatLockoutTimer(_lockoutSecondsLeft),
                    style: AppTypography.display.copyWith(
                      color: AppColors.error,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          AppTextField(
            label: 'Email',
            hint: 'nama@domain.com',
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
              if (!v.contains('@')) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Kata Sandi',
            hint: '••••••••',
            controller: _loginPasswordController,
            obscureText: _obscureLoginPassword,
            prefixIcon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Kata sandi wajib diisi' : null,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Lupa Kata Sandi
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ForgotPasswordSheet.show(
                  context,
                  initialEmail: _loginEmailController.text.trim(),
                );
              },
              child: Text(
                'Lupa kata sandi?',
                style: AppTypography.finePrint.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Submit Button
          AppButton(
            label: 'Masuk ke NutriCare',
            isLoading: authState.isLoading,
            onPressed: isLockedOut ? null : _handleLogin,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Or Divider
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'atau masuk dengan',
                  style: AppTypography.finePrint.copyWith(color: AppColors.textTertiary),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Google OAuth Button
          OutlinedButton.icon(
            onPressed: isLockedOut ? null : _handleGoogleLogin,
            icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Color(0xFFEA4335)),
            label: Text(
              'Lanjut dengan Google',
              style: AppTypography.captionStrong.copyWith(color: AppColors.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.input),
              backgroundColor: AppColors.bgSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Footer Reverify Link
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Belum verifikasi email? ',
                  style: AppTypography.finePrint.copyWith(color: AppColors.textSecondary),
                ),
                GestureDetector(
                  onTap: () {
                    context.go(
                      '/reverify?email=${Uri.encodeComponent(_loginEmailController.text.trim())}',
                    );
                  },
                  child: Text(
                    'Verifikasi Ulang',
                    style: AppTypography.finePrint.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab(AuthState authState) {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Nama Lengkap',
            hint: 'cth. Alvano Ghulwani',
            controller: _regNameController,
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) => v == null || v.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Email',
            hint: 'nama@domain.com',
            controller: _regEmailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
              if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Kata Sandi',
            hint: 'Minimal 8 karakter kombinasi',
            controller: _regPasswordController,
            obscureText: _obscureRegPassword,
            prefixIcon: Icons.lock_outline_rounded,
            suffix: IconButton(
              icon: Icon(
                _obscureRegPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
              if (!_passwordResult.isValid) return 'Kata sandi belum memenuhi kriteria';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Visual 5-Criteria Password Strength Meter
          PasswordStrengthMeter(result: _passwordResult),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Konfirmasi Kata Sandi',
            hint: 'Ulangi kata sandi di atas',
            controller: _regConfirmPasswordController,
            obscureText: _obscureRegConfirmPassword,
            prefixIcon: Icons.lock_clock_outlined,
            suffix: IconButton(
              icon: Icon(
                _obscureRegConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
              if (v != _regPasswordController.text) return 'Kata sandi tidak cocok';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // Checkbox UU PDP Consent
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _consentPDP,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => setState(() => _consentPDP = val ?? false),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Saya menyetujui pemrosesan data kesehatan dan profil gizi pribadi sesuai ketentuan UU No. 27/2022 tentang Pelindungan Data Pribadi (UU PDP).',
                    style: AppTypography.finePrint.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Register Submit Button
          AppButton(
            label: 'Daftar Akun Baru',
            isLoading: authState.isLoading,
            onPressed: _handleRegister,
          ),
        ],
      ),
    );
  }
}
