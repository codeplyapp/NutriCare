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
    with SingleTickerProviderStateMixin {
  late final AnimationController _mainController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _progressBar;
  late final Animation<double> _footerFade;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Animasi logo yang halus dan bersih
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    _progressBar = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.90, curve: Curves.easeInOutCubic),
      ),
    );

    _footerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.50, 0.95, curve: Curves.easeIn),
      ),
    );

    _mainController.forward();

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateNext();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateNext,
        child: SafeArea(
          child: SizedBox.expand(
            child: Column(
              children: [
                const Spacer(flex: 4),

                // Clean Logo Display
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 155,
                        height: 155,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.health_and_safety_rounded,
                            size: 80,
                            color: AppColors.frozenWater600,
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Sleek Minimal Progress Bar
                FadeTransition(
                  opacity: _logoFade,
                  child: SizedBox(
                    width: 140,
                    height: 3.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Container(
                            color: AppColors.border.withOpacity(0.6),
                          ),
                          AnimatedBuilder(
                            animation: _progressBar,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressBar.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.frozenWater600,
                                        AppColors.turquoise600,
                                        AppColors.richCerulean600,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 5),

                // Clean Minimal Footer
                FadeTransition(
                  opacity: _footerFade,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.richCerulean600,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Standar Kementerian Kesehatan RI',
                              style: AppTypography.captionStrong.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'NutriCare v1.0.0',
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
      ),
    );
  }
}
