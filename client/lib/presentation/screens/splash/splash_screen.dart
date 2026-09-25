import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/data/datasources/local_datasource.dart';
import 'package:nutricare/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _contentFade;
  late final Animation<double> _progressBar;
  late final Animation<double> _footerFade;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Controller untuk animasi masuk utama
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Controller untuk pernapasan halus / floating ambient glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.30, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.30, 0.65, curve: Curves.easeOut),
      ),
    );

    _progressBar = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.95, curve: Curves.easeInOutCubic),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();

    // Navigasi otomatis setelah splash selesai
    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateNext() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final authState = ref.read(authProvider);
    final localDataSource = LocalDataSource();

    if (authState.isAuthenticated) {
      if (!authState.isEmailVerified) {
        context.go('/email-verification');
      } else if (!authState.hasProfile) {
        context.go('/onboarding-profile');
      } else {
        context.go('/dashboard');
      }
    } else {
      final hasSeenOnboarding = await localDataSource.getHasSeenOnboarding();
      if (!hasSeenOnboarding) {
        context.go('/onboarding');
      } else {
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateNext, // Pengguna bisa tap untuk langsung lanjut
        child: Stack(
          children: [
            // 1. Ambient Background Gradients & Glows
            Positioned(
              top: -size.width * 0.35,
              left: -size.width * 0.2,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: size.width * 1.1,
                      height: size.width * 1.1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.frozenWater200.withOpacity(0.55),
                            AppColors.frozenWater50.withOpacity(0.2),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -size.width * 0.3,
              right: -size.width * 0.25,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + ((1 - _pulseController.value) * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: size.width * 1.0,
                      height: size.width * 1.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.richCerulean100.withOpacity(0.45),
                            AppColors.turquoise50.withOpacity(0.2),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Central Content (Logo + Brand Name + Tagline + Progress Bar)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Logo dengan Breathing Ambient Card
                    AnimatedBuilder(
                      animation: Listenable.merge([_mainController, _pulseController]),
                      builder: (context, child) {
                        final floatOffset = math.sin(_pulseController.value * 2 * math.pi) * 3;
                        return Transform.translate(
                          offset: Offset(0, floatOffset),
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Container(
                                width: 140,
                                height: 140,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(36),
                                  boxShadow: [
                                    // Ambient primary glow
                                    BoxShadow(
                                      color: AppColors.frozenWater500.withOpacity(0.28),
                                      blurRadius: 36,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 10),
                                    ),
                                    // Soft depth shadow
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.frozenWater200.withOpacity(0.8),
                                    width: 1.5,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback elegan bila terjadi kendala asset
                                      return Container(
                                        color: AppColors.frozenWater50,
                                        child: const Center(
                                          child: Icon(
                                            Icons.health_and_safety_rounded,
                                            size: 64,
                                            color: AppColors.frozenWater600,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Nama Brand & Badge Slogan
                    SlideTransition(
                      position: _contentSlide,
                      child: FadeTransition(
                        opacity: _contentFade,
                        child: Column(
                          children: [
                            // Judul NutriCare
                            Text(
                              'NutriCare',
                              style: AppTypography.h1.copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.6,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),

                            // Badge Slogan
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.frozenWater50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.frozenWater300.withOpacity(0.6),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    size: 13,
                                    color: AppColors.frozenWater700,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Kecerdasan Nutrisi & Kesehatan Pribadi',
                                    style: AppTypography.captionStrong.copyWith(
                                      color: AppColors.frozenWater800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            // Deskripsi Singkat
                            Text(
                              'Platform Manajemen Gizi Seimbang & Telekonsultasi Medis',
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    // Sleek Animated Gradient Progress Bar
                    FadeTransition(
                      opacity: _contentFade,
                      child: Column(
                        children: [
                          Container(
                            width: 170,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: AnimatedBuilder(
                              animation: _progressBar,
                              builder: (context, child) {
                                return FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progressBar.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.frozenWater500,
                                          AppColors.turquoise500,
                                          AppColors.richCerulean500,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.frozenWater500.withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          AnimatedBuilder(
                            animation: _progressBar,
                            builder: (context, child) {
                              String statusText = 'Memuat modul cerdas...';
                              if (_progressBar.value > 0.7) {
                                statusText = 'Menghubungkan data kesehatan...';
                              } else if (_progressBar.value > 0.35) {
                                statusText = 'Menyiapkan algoritma nutrisi...';
                              }
                              return Text(
                                statusText,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 4),

                    // 3. Footer / Standar Medis & Versi
                    FadeTransition(
                      opacity: _footerFade,
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 20,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 15,
                                  color: AppColors.richCerulean600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Standar Kementerian Kesehatan RI',
                                  style: AppTypography.captionStrong.copyWith(
                                    color: AppColors.richCerulean700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NutriCare v1.0.0 • AI-Driven Health & Clinical Nutrition',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 10.5,
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
          ],
        ),
      ),
    );
  }
}
