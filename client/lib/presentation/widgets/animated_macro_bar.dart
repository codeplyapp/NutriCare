import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_motion.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_typography.dart';

/// Implicit Animation Widget: Progress bar makronutrisi yang bertumbuh mulus dari 0% ke target
class AnimatedMacroBar extends StatelessWidget {
  final String label;
  final double current;
  final double target;
  final String unit;
  final Color color;

  const AnimatedMacroBar({
    super.key,
    required this.label,
    double? current,
    double? currentValue,
    double? target,
    double? targetValue,
    required this.unit,
    required this.color,
  })  : current = current ?? currentValue ?? 0.0,
        target = target ?? targetValue ?? 100.0;

  @override
  Widget build(BuildContext context) {
    final ratio = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.captionStrong.copyWith(fontSize: 13)),
            Text(
              '${current.toInt()} / ${target.toInt()} $unit',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: ratio),
          duration: AppMotion.resolve(context, AppMotion.sweep),
          curve: AppMotion.curveEmphasis,
          builder: (context, animatedValue, child) {
            return Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: AppShapes.pill,
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: animatedValue,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppShapes.pill,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
