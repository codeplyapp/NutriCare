import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_typography.dart';

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
