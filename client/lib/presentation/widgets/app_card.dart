import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_motion.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';

/// Kartu Fitur / Dashboard dengan micro-interaction implicit animation (Hover & Press feedback)
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final BorderRadius? borderRadius;
  final bool hasElevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.hasElevation = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? AppShapes.card;
    final effectivePadding = widget.padding ?? const EdgeInsets.all(AppSpacing.lg);

    final isInteractive = widget.onTap != null;
    final scale = _isPressed ? 0.98 : (_isHovered && isInteractive ? 1.01 : 1.0);

    return MouseRegion(
      onEnter: isInteractive ? (_) => setState(() => _isHovered = true) : null,
      onExit: isInteractive ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTapDown: isInteractive ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isInteractive ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isInteractive ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: AppMotion.resolve(context, AppMotion.micro),
          curve: AppMotion.curveStandard,
          child: AnimatedContainer(
            duration: AppMotion.resolve(context, AppMotion.micro),
            padding: effectivePadding,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.bgSurface,
              borderRadius: effectiveRadius,
              border: widget.border ?? Border.all(color: AppColors.border, width: 1),
              boxShadow: widget.hasElevation && widget.backgroundColor == null
                  ? (_isHovered && isInteractive
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ]
                      : AppShapes.softElevation)
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
