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
import 'package:nutricare/presentation/widgets/password_strength_meter.dart';

/// Layar Autentikasi NutriCare (AuthScreen)
/// Mengadopsi 100% tata letak, visual, dan struktur desain GoLantas / SIGAP
class AuthScreen extends ConsumerStatefulWidget {
  final int initialTabIndex; // 0: Masuk, 1: Daftar

  const AuthScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isLogin;
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

  // Visual Colors matching GoLantas design
  static const Color _brandBlue = Color(0xFF0077C0);
  static const Color _bgCard = Colors.white;
  static const Color _bgPage = Color(0xFFF8FAFC);
  static const Color _inputBg = Color(0xFFF8FAFC);
  static const Color _inputBorder = Color(0xFFE2E8F0);
  static const Color _labelColor = Color(0xFF334155);
  static const Color _placeholderColor = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialTabIndex == 0;

    _regPasswordController.addListener(_onPasswordChanged);
    _regNameController.addListener(_onRegisterDraftChanged);
    _regEmailController.addListener(_onRegisterDraftChanged);

    _loadRegisterDraft();
    _initLockoutTicker();
  }

  @override
  void dispose() {
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
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main White Card matching GoLantas
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    decoration: BoxDecoration(
                      color: _bgCard,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFEEF2F6), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x080F172A),
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Brand Logo Clean (Tanpa kartu pembungkus & tanpa teks lencana)
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 84,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title: "Selamat Datang!"
                        Text(
                          _isLogin ? 'Selamat Datang!' : 'Buat Akun Baru',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          _isLogin
                              ? 'Masuk ke portal edukasi dan pemantauan gizi sehat NutriCare.'
                              : 'Mulai perjalanan pemenuhan gizi optimal Anda bersama NutriCare.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Google OAuth Button (At Top)
                        OutlinedButton(
                          onPressed: isLockedOut ? null : _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: _inputBorder, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google 'G' icon
                              _buildGoogleIcon(),
                              const SizedBox(width: 10),
                              Text(
                                _isLogin ? 'Lanjutkan dengan Google' : 'Daftar dengan Google',
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Divider: "———— ATAU GUNAKAN EMAIL ————"
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'ATAU GUNAKAN EMAIL',
                                style: TextStyle(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Color(0xFFE2E8F0), thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Error Banner (if any)
                        if (authState.errorMessage != null && !isLockedOut) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Form Section
                        if (_isLogin)
                          _buildLoginForm(authState, isLockedOut)
                        else
                          _buildRegisterForm(authState),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Bottom Copyright Info
                  const Text(
                    '© 2026 NutriCare — Pelopor Kecerdasan Gizi & Kesehatan Digital',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
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

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Color(0xFF4285F4),
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthState authState, bool isLockedOut) {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lockout Banner
          if (isLockedOut) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF87171)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.lock_clock_rounded, color: Color(0xFFDC2626), size: 26),
                  const SizedBox(height: 6),
                  const Text(
                    'Akun Dikunci Sementara',
                    style: TextStyle(
                      color: Color(0xFF991B1B),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Terlalu banyak percobaan masuk yang salah (5x). Silakan coba lagi dalam:',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatLockoutTimer(_lockoutSecondsLeft),
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Label: ALAMAT EMAIL
          const Text(
            'ALAMAT EMAIL',
            style: TextStyle(
              color: _labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          _buildGoLantasField(
            controller: _loginEmailController,
            hintText: 'nama@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
              if (!v.contains('@')) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Label: KATA SANDI & Lupa kata sandi?
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'KATA SANDI',
                style: TextStyle(
                  color: _labelColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ForgotPasswordSheet.show(
                    context,
                    initialEmail: _loginEmailController.text.trim(),
                  );
                },
                child: const Text(
                  'Lupa kata sandi?',
                  style: TextStyle(
                    color: _brandBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildGoLantasField(
            controller: _loginPasswordController,
            hintText: 'Masukkan kata sandi',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureLoginPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureLoginPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: _placeholderColor,
              ),
              onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Kata sandi wajib diisi' : null,
          ),
          const SizedBox(height: 22),

          // Main Submit Button: "Masuk ke NutriCare ->"
          _buildPrimaryButton(
            text: 'Masuk ke NutriCare',
            showArrow: true,
            isLoading: authState.isLoading,
            onPressed: isLockedOut ? null : _handleLogin,
          ),
          const SizedBox(height: 22),

          // Footer Links
          Center(
            child: Column(
              children: [
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Belum memiliki akun NutriCare? ',
                      style: TextStyle(color: Color(0xFF475569), fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isLogin = false),
                      child: const Text(
                        'Daftar di sini',
                        style: TextStyle(
                          color: _brandBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Akun belum diverifikasi? ',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go(
                          '/reverify?email=${Uri.encodeComponent(_loginEmailController.text.trim())}',
                        );
                      },
                      child: const Text(
                        'Verifikasi ulang',
                        style: TextStyle(
                          color: _brandBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthState authState) {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // NAMA LENGKAP
          const Text(
            'NAMA LENGKAP',
            style: TextStyle(
              color: _labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          _buildGoLantasField(
            controller: _regNameController,
            hintText: 'Masukkan nama lengkap',
            prefixIcon: Icons.person_outline_rounded,
            validator: (v) => v == null || v.trim().isEmpty ? 'Nama lengkap wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // ALAMAT EMAIL
          const Text(
            'ALAMAT EMAIL',
            style: TextStyle(
              color: _labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          _buildGoLantasField(
            controller: _regEmailController,
            hintText: 'nama@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
              if (!v.contains('@') || !v.contains('.')) return 'Format email tidak valid';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // KATA SANDI
          const Text(
            'KATA SANDI',
            style: TextStyle(
              color: _labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          _buildGoLantasField(
            controller: _regPasswordController,
            hintText: 'Masukkan kata sandi',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureRegPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: _placeholderColor,
              ),
              onPressed: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Kata sandi wajib diisi';
              if (!_passwordResult.isValid) return 'Kata sandi belum memenuhi kriteria';
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Visual Password Strength Meter
          PasswordStrengthMeter(result: _passwordResult),
          const SizedBox(height: 14),

          // KONFIRMASI KATA SANDI
          const Text(
            'KONFIRMASI KATA SANDI',
            style: TextStyle(
              color: _labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          _buildGoLantasField(
            controller: _regConfirmPasswordController,
            hintText: 'Ulangi kata sandi di atas',
            prefixIcon: Icons.lock_clock_outlined,
            obscureText: _obscureRegConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: _placeholderColor,
              ),
              onPressed: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Konfirmasi kata sandi wajib diisi';
              if (v != _regPasswordController.text) return 'Kata sandi tidak cocok';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Consent UU PDP Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _consentPDP,
                  activeColor: _brandBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (val) => setState(() => _consentPDP = val ?? false),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Saya menyetujui pemrosesan data kesehatan dan profil gizi pribadi sesuai ketentuan UU No. 27/2022 tentang Pelindungan Data Pribadi (UU PDP).',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Register Button: "Daftar ke NutriCare ->"
          _buildPrimaryButton(
            text: 'Daftar ke NutriCare',
            showArrow: true,
            isLoading: authState.isLoading,
            onPressed: _handleRegister,
          ),
          const SizedBox(height: 18),

          // Footer Switch back to Login
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  'Sudah memiliki akun NutriCare? ',
                  style: TextStyle(color: Color(0xFF475569), fontSize: 13),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isLogin = true),
                  child: const Text(
                    'Masuk di sini',
                    style: TextStyle(
                      color: _brandBlue,
                      fontSize: 13,
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

  Widget _buildGoLantasField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: _placeholderColor,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: _inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: Icon(prefixIcon, color: _placeholderColor, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _inputBorder, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _inputBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _brandBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onPressed,
    bool showArrow = false,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: _brandBlue,
        disabledBackgroundColor: const Color(0xFF93C5FD),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showArrow) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ],
            ),
    );
  }
}
