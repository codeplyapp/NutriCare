import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_components.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';

/// Perakit ThemeData NutriCare resmi sesuai design.md v1.0
class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = AppColors.lightColorScheme();
    final textTheme = AppTypography.build();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgPage,
      colorScheme: colorScheme,
      textTheme: textTheme,

      // AppBar Theme (Clean White, 1px border)
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgSurface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),
        titleTextStyle: AppTypography.h2.copyWith(color: AppColors.textPrimary),
      ),

      // Card Theme (16px radius, 1px border, soft elevation in light mode)
      cardTheme: CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shape: AppShapes.cardShape(
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Button Themes (Filled, Outlined, Text)
      filledButtonTheme: FilledButtonThemeData(
        style: AppComponents.buttonPrimary,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppComponents.buttonSecondaryPill,
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppComponents.textLink,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppShapes.sm,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTypography.captionStrong,
        hintStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSurface,
        disabledColor: AppColors.border,
        selectedColor: AppColors.frozenWater100,
        secondarySelectedColor: AppColors.frozenWater100,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        labelStyle: AppTypography.caption,
        secondaryLabelStyle: AppTypography.captionStrong.copyWith(color: AppColors.frozenWater800),
        shape: AppShapes.pillShape(side: const BorderSide(color: AppColors.border)),
        elevation: 0,
        pressElevation: 0,
      ),
    );
  }
}
