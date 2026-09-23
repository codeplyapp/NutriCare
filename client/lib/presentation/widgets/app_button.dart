import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';

enum AppButtonVariant {
  primary,
  ai,
  medical,
  secondary,
  danger,
  dangerSolid,
  outline,
  dark,
  pearl,
  storeHero,
  text,
}

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;
    BorderRadius radius = AppShapes.btn; // 14px radius per design.md
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 13);
    TextStyle textStyle = AppTypography.buttonLabel;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        // Primary: fill frozen-water-600, text white, radius 14px
        bgColor = AppColors.primary;
        textColor = Colors.white;
        border = null;
        textStyle = AppTypography.buttonLabel.copyWith(color: Colors.white);
        break;

      case AppButtonVariant.ai:
        // AI Action: fill dark-amethyst-500, text white, radius 14px
        bgColor = AppColors.aiAccent;
        textColor = Colors.white;
        border = null;
        textStyle = AppTypography.buttonLabel.copyWith(color: Colors.white);
        break;

      case AppButtonVariant.medical:
        // Medical Action: fill rich-cerulean-500 / 600, text white, radius 14px
        bgColor = AppColors.medicalAccent;
        textColor = Colors.white;
        border = null;
        textStyle = AppTypography.buttonLabel.copyWith(color: Colors.white);
        break;

      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
        // Secondary/Ghost: border 1px border, text textPrimary, without fill
        bgColor = AppColors.bgSurface;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.border, width: 1);
        textStyle = AppTypography.buttonLabel.copyWith(color: AppColors.textPrimary);
        break;

      case AppButtonVariant.danger:
        // Soft Destructive: soft red fill, red border, red text & icon
        bgColor = const Color(0xFFFFF1F0);
        textColor = AppColors.error;
        border = Border.all(color: const Color(0xFFFECACA), width: 1);
        textStyle = AppTypography.buttonLabel.copyWith(color: AppColors.error, fontWeight: FontWeight.w600);
        break;

      case AppButtonVariant.dangerSolid:
        // Solid Destructive: fill red, text white
        bgColor = AppColors.error;
        textColor = Colors.white;
        border = null;
        textStyle = AppTypography.buttonLabel.copyWith(color: Colors.white);
        break;

      case AppButtonVariant.dark:
        bgColor = AppColors.surfaceBlack;
        textColor = AppColors.bodyOnDark;
        border = null;
        radius = AppShapes.sm;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
        textStyle = AppTypography.buttonUtility.copyWith(color: AppColors.bodyOnDark);
        break;

      case AppButtonVariant.pearl:
        bgColor = AppColors.bgPage;
        textColor = AppColors.textSecondary;
        border = Border.all(color: AppColors.border, width: 1);
        radius = AppShapes.sm;
        padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8);
        textStyle = AppTypography.caption.copyWith(color: AppColors.textSecondary);
        break;

      case AppButtonVariant.storeHero:
        bgColor = AppColors.primary;
        textColor = Colors.white;
        border = null;
        radius = AppShapes.btn;
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
        textStyle = AppTypography.buttonLabel.copyWith(color: Colors.white);
        break;

      case AppButtonVariant.text:
        bgColor = Colors.transparent;
        textColor = AppColors.primary;
        border = null;
        radius = AppShapes.none;
        padding = EdgeInsets.zero;
        textStyle = AppTypography.bodyStrong.copyWith(color: AppColors.primary);
        break;
    }

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    // Active state micro-interaction: transform scale 0.95
    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: padding,
          decoration: BoxDecoration(
            color: isEnabled ? bgColor : AppColors.border,
            borderRadius: radius,
            border: border,
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.variant == AppButtonVariant.danger
                            ? AppColors.error
                            : (widget.variant == AppButtonVariant.secondary ||
                                    widget.variant == AppButtonVariant.pearl
                                ? AppColors.primary
                                : Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, size: 18, color: isEnabled ? textColor : AppColors.inkMuted48),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                      Text(
                        widget.text,
                        style: textStyle.copyWith(
                          color: isEnabled ? textColor : AppColors.inkMuted48,
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
