import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';

/// Item data model untuk tab navigasi AppDock
class _DockTabItem {
  final IconData icon;
  final String label;

  const _DockTabItem({
    required this.icon,
    required this.label,
  });
}

/// Floating Curved Dome Bottom Navigation Dock 4 tab
/// Meniru presisi desain tab bar dengan active raised circular bubble & smooth curved dome.
class AppDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppDock({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_DockTabItem> _tabs = [
    _DockTabItem(icon: Icons.home_rounded, label: 'Beranda'),
    _DockTabItem(icon: Icons.restaurant_menu_rounded, label: 'Nutri Meal'),
    _DockTabItem(icon: Icons.medical_services_rounded, label: 'Nutri Doc'),
    _DockTabItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final duration = disableAnimations ? Duration.zero : const Duration(milliseconds: 280);

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 16, AppSpacing.md, AppSpacing.sm),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: currentIndex.toDouble(),
                end: currentIndex.toDouble(),
              ),
              duration: duration,
              curve: Curves.easeInOutCubic,
              builder: (context, animatedIndex, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    const height = 64.0;
                    final tabWidth = width / _tabs.length;
                    final activeCenterX = (animatedIndex + 0.5) * tabWidth;

                    return SizedBox(
                      width: width,
                      height: height,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Curved Background with Smooth Raised Dome
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _CurvedDockPainter(
                                activeIndex: animatedIndex,
                                tabCount: _tabs.length,
                                backgroundColor: AppColors.canvas,
                                shadowColor: Colors.black.withOpacity(0.08),
                                borderColor: AppColors.dividerSoft,
                              ),
                            ),
                          ),

                          // 2. Floating Circular Active Badge (Center of the Dome)
                          Positioned(
                            left: activeCenterX - 24,
                            top: -22,
                            child: GestureDetector(
                              onTap: () => onTap(currentIndex),
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryHover,
                                      AppColors.primary,
                                    ],
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x3000CCA0),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      _tabs[currentIndex].icon,
                                      key: ValueKey<int>(currentIndex),
                                      color: AppColors.onPrimary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 3. Tab Items Row (Labels & Inactive Icons)
                          Positioned.fill(
                            child: Row(
                              children: List.generate(_tabs.length, (index) {
                                final isSelected = currentIndex == index;
                                final tab = _tabs[index];

                                // Hitung seberapa dekat tab ini dengan posisi animasi
                                final distanceToActive = (animatedIndex - index).abs();
                                final activeProgress = (1.0 - distanceToActive).clamp(0.0, 1.0);

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => onTap(index),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          // Inactive Icon (fades and translates out when active)
                                          Opacity(
                                            opacity: (1.0 - activeProgress).clamp(0.0, 1.0),
                                            child: Transform.translate(
                                              offset: Offset(0, -6 * (1.0 - activeProgress)),
                                              child: Icon(
                                                tab.icon,
                                                size: 22,
                                                color: AppColors.inkMuted48,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),

                                          // Tab Label
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 8),
                                            child: Text(
                                              tab.label,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: isSelected
                                                  ? AppTypography.captionStrong.copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primary,
                                                    )
                                                  : AppTypography.caption.copyWith(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w500,
                                                      color: AppColors.inkMuted48,
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar background tab bar dengan dome lengkung halus
class _CurvedDockPainter extends CustomPainter {
  final double activeIndex;
  final int tabCount;
  final Color backgroundColor;
  final Color shadowColor;
  final Color borderColor;

  _CurvedDockPainter({
    required this.activeIndex,
    required this.tabCount,
    required this.backgroundColor,
    required this.shadowColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double tabWidth = w / tabCount;
    final double cx = (activeIndex + 0.5) * tabWidth;

    const double domeHeight = 16.0;
    const double domeHalfWidth = 34.0;
    const double rTop = 16.0;
    const double rBottom = 28.0;

    final path = Path();

    // 1. Mulai dari sudut kiri atas
    path.moveTo(0, rTop);
    path.quadraticBezierTo(0, 0, rTop, 0);

    // 2. Garis lurus ke awal lengkungan dome
    final double domeStart = (cx - domeHalfWidth).clamp(rTop, w - rTop);
    final double domeEnd = (cx + domeHalfWidth).clamp(rTop, w - rTop);
    final double domeCenter = cx.clamp(rTop, w - rTop);

    path.lineTo(domeStart, 0);

    // 3. S-curve halus (Cubic Bezier) menuju puncak dome dan kembali ke baseline
    final double cp1x = domeStart + (domeCenter - domeStart) * 0.35;
    final double cp2x = domeCenter - (domeCenter - domeStart) * 0.35;
    final double cp3x = domeCenter + (domeEnd - domeCenter) * 0.35;
    final double cp4x = domeEnd - (domeEnd - domeCenter) * 0.35;

    path.cubicTo(cp1x, 0, cp2x, -domeHeight, domeCenter, -domeHeight);
    path.cubicTo(cp3x, -domeHeight, cp4x, 0, domeEnd, 0);

    // 4. Garis lurus ke sudut kanan atas
    path.lineTo(w - rTop, 0);
    path.quadraticBezierTo(w, 0, w, rTop);

    // 5. Garis ke sudut kanan bawah
    path.lineTo(w, h - rBottom);
    path.quadraticBezierTo(w, h, w - rBottom, h);

    // 6. Garis bawah ke sudut kiri bawah
    path.lineTo(rBottom, h);
    path.quadraticBezierTo(0, h, 0, h - rBottom);

    path.close();

    // Gambar shadow halus
    canvas.drawShadow(path, shadowColor, 12.0, true);

    // Gambar warna background
    final paintFill = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paintFill);

    // Gambar hairline border lembut
    final paintBorder = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, paintBorder);
  }

  @override
  bool shouldRepaint(covariant _CurvedDockPainter oldDelegate) {
    return oldDelegate.activeIndex != activeIndex ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.shadowColor != shadowColor ||
        oldDelegate.borderColor != borderColor;
  }
}

/// Floating AI Assistant Button (Nutri Mate AI)
/// Mengikuti panduan token warna Apple & Dark Amethyst NutriCare.
class FloatingNutriMateButton extends StatefulWidget {
  final VoidCallback? onTap;

  const FloatingNutriMateButton({
    super.key,
    this.onTap,
  });

  @override
  State<FloatingNutriMateButton> createState() => _FloatingNutriMateButtonState();
}

class _FloatingNutriMateButtonState extends State<FloatingNutriMateButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.94 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              context.push('/nutri-mate');
            }
          },
          borderRadius: AppShapes.pill,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkAmethyst600,
                  AppColors.darkAmethyst500,
                ],
              ),
              borderRadius: AppShapes.pill,
              border: Border.all(
                color: AppColors.darkAmethyst400.withOpacity(0.6),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x405637C8),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: Color(0x15000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing AI Icon
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.frozenWater200,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),

                // Label Text
                Text(
                  'Tanya AI',
                  style: AppTypography.captionStrong.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 6),

                // Online indicator dot
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.frozenWater400,
                    shape: BoxShape.circle,
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

