import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutricare/core/theme/app_colors.dart';

/// Tipografi NutriCare berbasis Plus Jakarta Sans (Headings) & Inter (Body)
/// Sesuai design.md v1.0
class AppTypography {
  // Plus Jakarta Sans helper for Display and Headings
  static TextStyle _pjs({
    required double fontSize,
    required FontWeight fontWeight,
    double height = 1.3,
    double letterSpacing = -0.2,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // Inter helper for Body and Labels
  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    double height = 1.5,
    double letterSpacing = 0,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  // ==========================================
  // TOKEN RESMI DESIGN.MD
  // ==========================================

  /// Display (headline onboarding): Plus Jakarta Sans 28–32px, 600
  static TextStyle get display => _pjs(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  /// H1 (judul layar): Plus Jakarta Sans 22px, 600
  static TextStyle get h1 => _pjs(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  /// H2 (judul kartu/section): Plus Jakarta Sans 18px, 500/600
  static TextStyle get h2 => _pjs(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  /// Body: Inter 15–16px, 400
  static TextStyle get body => _inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.55,
      );

  /// Body Strong: Inter 15px, 600
  static TextStyle get bodyStrong => _inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.45,
      );

  /// Body kecil / Caption: Inter 13px, 400
  static TextStyle get caption => _inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textSecondary,
      );

  /// Caption Strong: Inter 13px, 600
  static TextStyle get captionStrong => _inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: AppColors.textPrimary,
      );

  /// Label Tombol: Inter 15px, 500/600
  static TextStyle get buttonLabel => _inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.0,
        color: Colors.white,
      );

  /// Fine Print / Micro: Inter 11–12px, 400
  static TextStyle get finePrint => _inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColors.textSecondary,
      );

  static TextStyle get microLegal => _inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: AppColors.inkMuted48,
      );

  // Backward-compatible aliases for legacy token calls
  static TextStyle get heroDisplay => display;
  static TextStyle get displayLg => display;
  static TextStyle get displayMd => display;
  static TextStyle get lead => h1;
  static TextStyle get leadAiry => h1;
  static TextStyle get tagline => h2;
  static TextStyle get buttonLarge => buttonLabel;
  static TextStyle get buttonUtility => _inter(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2);
  static TextStyle get denseLink => _inter(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.primary);
  static TextStyle get navLink => _inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.bodyOnDark);

  /// TextTheme resmi Flutter
  static TextTheme build() {
    return TextTheme(
      displayLarge: display,
      displayMedium: display,
      displaySmall: h1,
      headlineMedium: h1,
      headlineSmall: h2,
      titleLarge: h2,
      titleMedium: bodyStrong,
      titleSmall: captionStrong,
      bodyLarge: body,
      bodyMedium: caption,
      bodySmall: finePrint,
      labelLarge: buttonLabel,
      labelMedium: buttonUtility,
      labelSmall: microLegal,
    );
  }
}
