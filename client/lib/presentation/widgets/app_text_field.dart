import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool isSearch;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.isSearch = false,
  });

  Widget? get effectiveSuffix => suffix ?? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: AppTypography.captionStrong.copyWith(color: AppColors.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          style: AppTypography.body.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            filled: true,
            fillColor: AppColors.canvas,
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSearch ? AppSpacing.lg : AppSpacing.md,
              vertical: isSearch ? AppSpacing.sm : AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: isSearch ? AppShapes.pill : AppShapes.md,
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: isSearch ? AppShapes.pill : AppShapes.md,
              borderSide: const BorderSide(color: AppColors.hairline, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: isSearch ? AppShapes.pill : AppShapes.md,
              borderSide: const BorderSide(color: AppColors.primaryFocus, width: 2),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.inkMuted48, size: 18)
                : null,
            suffixIcon: effectiveSuffix,
          ),
        ),
      ],
    );
  }
}
