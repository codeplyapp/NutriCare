import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/data/datasources/local_datasource.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

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

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    // Data warna per slide
    final List<Color> accentColors = [
      const Color(0xFFEA580C), // Slide 1: Orange
      const Color(0xFF0284C7), // Slide 2: Sky Blue
      const Color(0xFF7C3AED), // Slide 3: Purple
    ];

    final currentAccent = accentColors[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // PageView Utama
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _buildPage1(size, topPadding),
              _buildPage2(size, topPadding),
              _buildPage3(size, topPadding),
            ],
          ),

          // Tombol Skip di Kanan Atas
          Positioned(
            top: topPadding + 12,
            right: 20,
            child: GestureDetector(
              onTap: _navigateToAuth,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Skip',
                  style: AppTypography.captionStrong.copyWith(
                    color: const Color(0xFF1E293B),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Bar: Tombol "Mulai Sekarang" + Dots Indicator di Bawahnya
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPadding + 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol "Mulai Sekarang"
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            'Mulai Sekarang',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: currentAccent,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Indicator Dots di bawah tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4.5),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? currentAccent
                            : const Color(0xFFE2E8F0),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SLIDE 1: Mulai Hidup Lebih Sehat
  // ==========================================
  Widget _buildPage1(Size size, double topPadding) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFF9F3),
            Color(0xFFFFF4EC),
            Color(0xFFFFEBDD),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.04),

            // Header Teks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Mulai Hidup\n',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Lebih Sehat,\n',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEA580C),
                            height: 1.18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Sedikit Demi Sedikit',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEA580C),
                            height: 1.18,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kebiasaan kecil setiap hari membawa perubahan besar untuk tubuh yang lebih sehat.',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF64748B),
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Area Ilustrasi Maskot & Floating Chips
            SizedBox(
              height: size.height * 0.52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Maskot Dokter memegang apel & salad
                  Positioned(
                    left: -size.width * 0.08,
                    bottom: 0,
                    width: size.width * 0.88,
                    height: size.height * 0.52,
                    child: Image.asset(
                      'assets/images/onboarding/onboarding_doc_1.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomLeft,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),

                  // Floating Chips Vertikal di Kanan
                  Positioned(
                    right: 20,
                    top: size.height * 0.02,
                    child: _buildVerticalChip(
                      iconWidget: const Text(
                        '🍎',
                        style: TextStyle(fontSize: 24),
                      ),
                      title: 'Nutrisi\nSeimbang',
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: size.height * 0.16,
                    child: _buildVerticalChip(
                      iconWidget: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_run_rounded,
                          color: Color(0xFF0284C7),
                          size: 20,
                        ),
                      ),
                      title: 'Gaya Hidup\nAktif',
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: size.height * 0.30,
                    child: _buildVerticalChip(
                      iconWidget: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFFEF4444),
                          size: 18,
                        ),
                      ),
                      title: 'Tubuh\nLebih Sehat',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.12),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SLIDE 2: Pahami Nutrisimu
  // ==========================================
  Widget _buildPage2(Size size, double topPadding) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F9FF),
            Color(0xFFE5F4FD),
            Color(0xFFD6EEFC),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.04),

            // Header Teks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pahami Nutrisimu,\n',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Kenali Dirimu Lebih Baik',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0284C7),
                            height: 1.18,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Catat makananmu, pantau asupan nutrisi, dan dapatkan rekomendasi sesuai kebutuhanmu.',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF64748B),
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Area Ilustrasi Maskot dengan Kartu Nutrisi & Bubble
            SizedBox(
              height: size.height * 0.52,
              child: Center(
                child: Image.asset(
                  'assets/images/onboarding/onboarding_doc_2.png',
                  width: size.width * 0.95,
                  height: size.height * 0.52,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.12),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SLIDE 3: Capai Tujuanmu
  // ==========================================
  Widget _buildPage3(Size size, double topPadding) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFF3E8FF),
            Color(0xFFE9D5FF),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height * 0.04),

            // Header Teks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Capai Tujuanmu,\n',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            height: 1.18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Bersama Setiap Langkah',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                            height: 1.18,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dapatkan panduan, tips, dan motivasi untuk hidup lebih sehat dan percaya diri setiap hari.',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF64748B),
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Area Ilustrasi Maskot dengan Floating Achievement Chips
            SizedBox(
              height: size.height * 0.52,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Maskot Dokter Selebrasi
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/onboarding/onboarding_doc_3.png',
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),

                  // Chip 1 (Kiri Atas): Capai Target
                  Positioned(
                    left: 20,
                    top: size.height * 0.08,
                    child: _buildVerticalChip(
                      iconWidget: const Icon(
                        Icons.track_changes_rounded,
                        color: Color(0xFF7C3AED),
                        size: 26,
                      ),
                      title: 'Capai\nTarget',
                    ),
                  ),

                  // Chip 2 (Kanan Atas): Pantau Perkembangan
                  Positioned(
                    right: 20,
                    top: size.height * 0.09,
                    child: _buildVerticalChip(
                      iconWidget: const Icon(
                        Icons.bar_chart_rounded,
                        color: Color(0xFF7C3AED),
                        size: 26,
                      ),
                      title: 'Pantau\nPerkembangan',
                    ),
                  ),

                  // Chip 3 (Kanan Bawah): Rasakan Perubahannya
                  Positioned(
                    right: 20,
                    top: size.height * 0.28,
                    child: _buildVerticalChip(
                      iconWidget: const Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: Color(0xFF7C3AED),
                        size: 26,
                      ),
                      title: 'Rasakan\nPerubahannya',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.12),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER: Widget Floating Chip Vertikal
  // ==========================================
  Widget _buildVerticalChip({
    required Widget iconWidget,
    required String title,
  }) {
    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            child: Center(child: iconWidget),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              height: 1.22,
            ),
          ),
        ],
      ),
    );
  }
}
