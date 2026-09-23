import 'package:flutter/material.dart';
import 'package:nutricare/core/theme/app_colors.dart';
import 'package:nutricare/core/theme/app_shapes.dart';
import 'package:nutricare/core/theme/app_spacing.dart';
import 'package:nutricare/core/theme/app_typography.dart';

/// Gaya komponen resmi NutriCare sesuai LIB_THEME.md & DESIGN.md
class AppComponents {
  // ==========================================
  // BUTTON STYLES
  // ==========================================

  /// button-primary: bg primary, teks onPrimary via body 17, radius pill, padding 22x11
  static ButtonStyle get buttonPrimary => ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return AppColors.hairline;
          return AppColors.primary;
        }),
        foregroundColor: WidgetStateProperty.all(AppColors.onPrimary),
        textStyle: WidgetStateProperty.all(AppTypography.body.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        )),
        shape: WidgetStateProperty.all(AppShapes.pillShape()),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        ),
        elevation: WidgetStateProperty.all(0),
        splashFactory: NoSplash.splashFactory,
      );

  /// button-secondary-pill: teks primary, border 1px primary, radius pill, padding 22x11
  static ButtonStyle get buttonSecondaryPill => ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.canvas),
        foregroundColor: WidgetStateProperty.all(AppColors.primary),
        textStyle: WidgetStateProperty.all(AppTypography.body.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        )),
        shape: WidgetStateProperty.all(
          AppShapes.pillShape(side: const BorderSide(color: AppColors.primary, width: 1)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        ),
        elevation: WidgetStateProperty.all(0),
      );

  /// button-dark-utility: bg dark-amethyst-950, radius sm (8), labelMedium (14/400)
  static ButtonStyle get buttonDarkUtility => ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surfaceBlack),
        foregroundColor: WidgetStateProperty.all(AppColors.bodyOnDark),
        textStyle: WidgetStateProperty.all(AppTypography.buttonUtility),
        shape: WidgetStateProperty.all(AppShapes.smShape()),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        ),
        elevation: WidgetStateProperty.all(0),
      );

  /// button-pearl-capsule: bg surface-pearl, teks tersier, radius md (11), padding 14x8
  static ButtonStyle get buttonPearlCapsule => ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.surfacePearl),
        foregroundColor: WidgetStateProperty.all(AppColors.inkMuted80),
        textStyle: WidgetStateProperty.all(AppTypography.caption),
        shape: WidgetStateProperty.all(AppShapes.mdShape()),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
        elevation: WidgetStateProperty.all(0),
      );

  /// button-store-hero: bg primary, labelLarge (18/300), padding 28x14, radius pill
  static ButtonStyle get buttonStoreHero => ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.primary),
        foregroundColor: WidgetStateProperty.all(AppColors.onPrimary),
        textStyle: WidgetStateProperty.all(AppTypography.buttonLarge),
        shape: WidgetStateProperty.all(AppShapes.pillShape()),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
        elevation: WidgetStateProperty.all(0),
      );

  /// text-link: teks primary, body 17
  static ButtonStyle get textLink => ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColors.primary),
        textStyle: WidgetStateProperty.all(AppTypography.body),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        elevation: WidgetStateProperty.all(0),
      );

  /// text-link-on-dark: teks rich-cerulean-400 (primary-on-dark) — hanya di surface gelap
  static ButtonStyle get textLinkOnDark => ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColors.primaryOnDark),
        textStyle: WidgetStateProperty.all(AppTypography.body),
        padding: WidgetStateProperty.all(EdgeInsets.zero),
        elevation: WidgetStateProperty.all(0),
      );

  // ==========================================
  // CARD DECORATION
  // ==========================================

  /// store-utility-card: radius lg (18), border hairline 1px, padding lg (24)
  static BoxDecoration get storeUtilityCardDecoration => BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppShapes.lg,
        border: Border.all(color: AppColors.hairline, width: 1),
      );

  /// Dark tile card decoration (surfaceTile1)
  static BoxDecoration get darkTileDecoration => BoxDecoration(
        color: AppColors.surfaceTile1,
        borderRadius: AppShapes.lg,
        border: Border.all(color: AppColors.surfaceTile2, width: 1),
      );
}
