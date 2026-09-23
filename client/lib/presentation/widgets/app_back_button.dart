import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_motion.dart';
import 'package:nutricare/core/theme/app_typography.dart';

/// Tombol Kembali (Back Button) sesuai token spesifikasi DESIGN.md
/// - Hit-area 44x44
/// - Chevron Action/Primary color
/// - Smart fallback navigation jika canPop() bernilai false pada GoRouter
class AppBackButton extends StatelessWidget {
  final String fallbackLocation;
  final String? label;
  final VoidCallback? onCustomPressed;
  final Color? color;

  const AppBackButton({
    super.key,
    this.fallbackLocation = '/dashboard',
    this.label,
    this.onCustomPressed,
    this.color,
  });

  void _handleBack(BuildContext context) {
    if (onCustomPressed != null) {
      onCustomPressed!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primaryHover;

    if (label != null) {
      return InkWell(
        onTap: () => _handleBack(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: effectiveColor,
              ),
              const SizedBox(width: 4),
              Text(
                label!,
                style: AppTypography.captionStrong.copyWith(
                  color: effectiveColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: effectiveColor,
          ),
          tooltip: 'Kembali',
          splashRadius: 22,
          onPressed: () => _handleBack(context),
        ),
      ),
    );
  }
}
