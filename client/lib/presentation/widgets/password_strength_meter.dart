import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';
import 'package:nutricare/core/utils/password_policy.dart';

/// Widget Meter Kekuatan Kata Sandi dengan Bar Multi-Segment dan 5 Checklist Kriteria
/// Sesuai pola desain GoLantas / SIGAP
class PasswordStrengthMeter extends StatelessWidget {
  final PasswordValidationResult result;
  final bool showCriteriaList;

  const PasswordStrengthMeter({
    super.key,
    required this.result,
    this.showCriteriaList = true,
  });

  Color _getStrengthColor() {
    switch (result.strengthLevel) {
      case PasswordStrengthLevel.veryWeak:
      case PasswordStrengthLevel.weak:
        return AppColors.error;
      case PasswordStrengthLevel.medium:
        return AppColors.warning;
      case PasswordStrengthLevel.strong:
        return AppColors.richCerulean500;
      case PasswordStrengthLevel.veryStrong:
        return AppColors.frozenWater600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _getStrengthColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Indicator Level
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kekuatan Sandi:',
              style: AppTypography.finePrint.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              result.strengthLabel,
              style: AppTypography.finePrint.copyWith(
                color: activeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 4-Segment Progress Bar
        Row(
          children: List.generate(4, (index) {
            final isFilled = (index + 1) <= (result.scorePercent * 4).round();
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? 4.0 : 0.0,
                ),
                decoration: BoxDecoration(
                  color: isFilled ? activeColor : AppColors.border,
                  borderRadius: AppShapes.pill,
                ),
              ),
            );
          }),
        ),

        if (showCriteriaList) ...[
          const SizedBox(height: AppSpacing.sm),
          // 5 Checklist Kriteria
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: 4,
            children: result.criteria.map((criterion) {
              final isMet = criterion.isMet;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: isMet ? AppColors.frozenWater600 : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    criterion.label,
                    style: AppTypography.finePrint.copyWith(
                      color: isMet ? AppColors.textPrimary : AppColors.textTertiary,
                      fontSize: 11,
                      fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
