import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/data/datasources/local_datasource.dart';

/// Data model untuk setiap halaman onboarding
class _OnboardingPageData {
  final String title;
  final String titleHighlight;
  final String description;
  final String mascotImage;
  final List<_FeatureChip> features;
  final Color bgGradientStart;
  final Color bgGradientEnd;
  final Color accentColor;

  const _OnboardingPageData({
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.mascotImage,
    required this.features,
    required this.bgGradientStart,
    required this.bgGradientEnd,
    required this.accentColor,
  });
}

class _FeatureChip {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      title: 'Mulai Hidup\n',
      titleHighlight: 'Lebih Sehat, Sedikit\nDemi Sedikit',
      description:
          'Kebiasaan kecil setiap hari membawa perubahan besar untuk tubuh yang lebih sehat.',
      mascotImage: 'assets/images/mascot/mascot_presenting.png',
      features: [
        _FeatureChip(
          icon: Icons.apple,
          label: 'Nutrisi\nSeimbang',
          bgColor: AppColors.frozenWater50,
          iconColor: AppColors.frozenWater600,
        ),
        _FeatureChip(
          icon: Icons.directions_run,
          label: 'Gaya Hidup\nAktif',
          bgColor: AppColors.turquoise50,
          iconColor: AppColors.turquoise600,
        ),
        _FeatureChip(
          icon: Icons.favorite,
          label: 'Tubuh\nLebih Sehat',
          bgColor: AppColors.darkAmethyst50,
          iconColor: AppColors.darkAmethyst500,
        ),
      ],
      bgGradientStart: AppColors.frozenWater50,
      bgGradientEnd: const Color(0xFFFFF7ED),
      accentColor: AppColors.frozenWater600,
    ),
    _OnboardingPageData(
      title: 'Pahami Nutrisimu,\n',
      titleHighlight: 'Kenali Dirimu\nLebih Baik',
      description:
          'Catat makananmu, pantau asupan nutrisi, dan dapatkan rekomendasi sesuai kebutuhanmu.',
      mascotImage: 'assets/images/mascot/doctor_pointing.png',
      features: [
        _FeatureChip(
          icon: Icons.local_fire_department,
          label: 'Kalori\nHarian',
          bgColor: AppColors.richCerulean50,
          iconColor: AppColors.richCerulean500,
        ),
        _FeatureChip(
          icon: Icons.egg_alt,
          label: 'Protein',
          bgColor: AppColors.turquoise50,
          iconColor: AppColors.turquoise600,
        ),
        _FeatureChip(
          icon: Icons.grain,
          label: 'Karbohidrat',
          bgColor: AppColors.frozenWater50,
          iconColor: AppColors.frozenWater600,
        ),
      ],
      bgGradientStart: AppColors.richCerulean50,
      bgGradientEnd: AppColors.turquoise50,
      accentColor: AppColors.richCerulean500,
    ),
    _OnboardingPageData(
      title: 'Capai Tujuanmu,\n',
      titleHighlight: 'Bersama Setiap\nLangkah',
      description:
          'Dapatkan panduan, tips, dan motivasi untuk hidup lebih sehat dan percaya diri setiap hari.',
      mascotImage: 'assets/images/mascot/doctor_thumbs_up.png',
      features: [
        _FeatureChip(
          icon: Icons.gps_fixed,
          label: 'Capai\nTarget',
          bgColor: AppColors.darkAmethyst50,
          iconColor: AppColors.darkAmethyst500,
        ),
        _FeatureChip(
          icon: Icons.insights,
          label: 'Pantau\nPerkembangan',
          bgColor: AppColors.richCerulean50,
          iconColor: AppColors.richCerulean500,
        ),
        _FeatureChip(
          icon: Icons.emoji_events,
          label: 'Rasakan\nPerubahannya',
          bgColor: AppColors.frozenWater50,
          iconColor: AppColors.frozenWater600,
        ),
      ],
      bgGradientStart: AppColors.darkAmethyst50,
      bgGradientEnd: AppColors.turquoise50,
      accentColor: AppColors.darkAmethyst500,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _navigateToAuth() {
    LocalDataSource().setHasSeenOnboarding(true);
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView utama
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: _pages[index],
                isActive: _currentPage == index,
              );
            },
          ),

          // Tombol Skip di kanan atas
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 20,
            child: TextButton(
              onPressed: _navigateToAuth,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.bgSurface.withOpacity(0.85),
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'Skip',
                style: AppTypography.captionStrong.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // Bottom area: Dots + Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.0),
                    Colors.white.withOpacity(0.9),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tombol CTA "Mulai Sekarang"
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        } else {
                          _navigateToAuth();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.bgSurface,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage < _pages.length - 1
                                ? 'Mulai Sekarang'
                                : 'Ayo Mulai!',
                            style: AppTypography.bodyStrong.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: _pages[_currentPage].accentColor,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? _pages[_currentPage].accentColor
                              : AppColors.border,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget halaman tunggal onboarding
class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;
  final bool isActive;

  const _OnboardingPage({
    required this.data,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.bgGradientStart,
            data.bgGradientEnd,
            Colors.white,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: size.height * 0.18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),

              // Judul
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: data.title,
                        style: AppTypography.display.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: data.titleHighlight,
                        style: AppTypography.display.copyWith(
                          color: data.accentColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Deskripsi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  data.description,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Mascot + Feature Chips layout
              SizedBox(
                height: size.height * 0.48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Mascot Image
                    Positioned(
                      left: 0,
                      bottom: 0,
                      width: size.width * 0.65,
                      child: AnimatedOpacity(
                        opacity: isActive ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: AnimatedSlide(
                          offset: isActive
                              ? Offset.zero
                              : const Offset(0, 0.1),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          child: Image.asset(
                            data.mascotImage,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: size.width * 0.55,
                              height: size.width * 0.55,
                              decoration: BoxDecoration(
                                color: data.bgGradientStart.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 80,
                                color: data.accentColor.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Feature Chips yang melayang di sisi kanan
                    ...List.generate(data.features.length, (i) {
                      final chip = data.features[i];
                      final topOffset = i * (size.height * 0.13);
                      return Positioned(
                        right: AppSpacing.lg,
                        top: topOffset + 10,
                        child: AnimatedOpacity(
                          opacity: isActive ? 1.0 : 0.0,
                          duration: Duration(
                            milliseconds: 400 + (i * 150),
                          ),
                          child: AnimatedSlide(
                            offset: isActive
                                ? Offset.zero
                                : const Offset(0.3, 0),
                            duration: Duration(
                              milliseconds: 500 + (i * 150),
                            ),
                            curve: Curves.easeOutCubic,
                            child: _FeatureChipCard(chip: chip),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu fitur kecil yang muncul di samping maskot
class _FeatureChipCard extends StatelessWidget {
  final _FeatureChip chip;

  const _FeatureChipCard({required this.chip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: chip.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(chip.icon, color: chip.iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Text(
            chip.label,
            style: AppTypography.captionStrong.copyWith(
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
