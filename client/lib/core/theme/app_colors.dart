import 'package:flutter/material.dart';

/// Skala Warna Brand & Semantic ColorScheme NutriCare
/// Sesuai design.md v1.0
class AppColors {
  // ==========================================
  // 1. SKALA BRAND (4 KELUARGA x 11 SHADE)
  // ==========================================

  // frozen-water (mint/hijau-tosca terang) - Brand / Primary
  static const Color frozenWater50 = Color(0xFFE5FFF9);
  static const Color frozenWater100 = Color(0xFFCCFFF4);
  static const Color frozenWater200 = Color(0xFF99FFE9);
  static const Color frozenWater300 = Color(0xFF66FFDE);
  static const Color frozenWater400 = Color(0xFF33FFD3);
  static const Color frozenWater500 = Color(0xFF00FFC8);
  static const Color frozenWater600 = Color(0xFF00CCA0);
  static const Color frozenWater700 = Color(0xFF009978);
  static const Color frozenWater800 = Color(0xFF006650);
  static const Color frozenWater900 = Color(0xFF003328);
  static const Color frozenWater950 = Color(0xFF00241C);

  // dark-amethyst (ungu) - AI / Nutri Mate
  static const Color darkAmethyst50 = Color(0xFFEEEBFA);
  static const Color darkAmethyst100 = Color(0xFFDDD7F4);
  static const Color darkAmethyst200 = Color(0xFFBCAFE9);
  static const Color darkAmethyst300 = Color(0xFF9A87DE);
  static const Color darkAmethyst400 = Color(0xFF785FD3);
  static const Color darkAmethyst500 = Color(0xFF5637C8);
  static const Color darkAmethyst600 = Color(0xFF452CA0);
  static const Color darkAmethyst700 = Color(0xFF342178);
  static const Color darkAmethyst800 = Color(0xFF231650);
  static const Color darkAmethyst900 = Color(0xFF110B28);
  static const Color darkAmethyst950 = Color(0xFF0C081C);

  // turquoise (pirus) - Secondary / Konten Edukasi
  static const Color turquoise50 = Color(0xFFEBF9F8);
  static const Color turquoise100 = Color(0xFFD7F4F0);
  static const Color turquoise200 = Color(0xFFB0E8E2);
  static const Color turquoise300 = Color(0xFF88DDD3);
  static const Color turquoise400 = Color(0xFF61D1C4);
  static const Color turquoise500 = Color(0xFF39C6B5);
  static const Color turquoise600 = Color(0xFF2E9E91);
  static const Color turquoise700 = Color(0xFF22776D);
  static const Color turquoise800 = Color(0xFF174F49);
  static const Color turquoise900 = Color(0xFF0B2824);
  static const Color turquoise950 = Color(0xFF081C19);

  // rich-cerulean (biru) - Medis / Dokter Gizi
  static const Color richCerulean50 = Color(0xFFEAF4FB);
  static const Color richCerulean100 = Color(0xFFD5E9F6);
  static const Color richCerulean200 = Color(0xFFAAD3EE);
  static const Color richCerulean300 = Color(0xFF80BDE5);
  static const Color richCerulean400 = Color(0xFF56A6DC);
  static const Color richCerulean500 = Color(0xFF2B90D4);
  static const Color richCerulean600 = Color(0xFF2373A9);
  static const Color richCerulean700 = Color(0xFF1A577F);
  static const Color richCerulean800 = Color(0xFF113A55);
  static const Color richCerulean900 = Color(0xFF091D2A);
  static const Color richCerulean950 = Color(0xFF06141E);

  // ==========================================
  // 2. PEMETAAN SEMANTIK DESIGN.MD
  // ==========================================

  // Brand / Primary: Frozen Water (CTA, Logo, Target Gizi, BMI)
  static const Color primary = frozenWater600; // #00cca0
  static const Color primaryHover = frozenWater700; // #009978
  static const Color primaryLight = frozenWater500; // #00ffc8
  static const Color primaryFocus = frozenWater500;
  static const Color primaryOnDark = frozenWater400;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryLight = frozenWater900; // #003328

  // AI / Nutri Mate (Dark Amethyst)
  static const Color aiAccent = darkAmethyst500; // #5637c8
  static const Color aiSurface = darkAmethyst50; // #eeebfa
  static const Color aiText = darkAmethyst800; // #231650
  static const Color onAi = Color(0xFFFFFFFF);

  // Secondary / Konten Edukasi (Turquoise)
  static const Color secondary = turquoise500; // #39c6b5
  static const Color secondarySurface = turquoise50; // #ebf9f8
  static const Color secondaryText = turquoise900; // #0b2824
  static const Color secondaryContainer = turquoise100;
  static const Color onSecondaryContainer = turquoise900;

  // Medis / Dokter Gizi (Rich Cerulean)
  static const Color medicalAccent = richCerulean500; // #2b90d4
  static const Color medicalPrimary = richCerulean600; // #2373a9
  static const Color medicalSurface = richCerulean50; // #eaf4fb
  static const Color medicalText = richCerulean800; // #113a55
  static const Color onMedical = Color(0xFFFFFFFF);

  // Background, Surface, & Typography Netral
  static const Color bgPage = Color(0xFFFBFFFE);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color bgSurfaceSecondary = Color(0xFFF7FBF9);
  static const Color textPrimary = Color(0xFF0B1210);
  static const Color textSecondary = Color(0xFF5C6663);
  static const Color textTertiary = Color(0xFF8A9491);
  static const Color border = Color(0xFFE4E7E6);
  static const Color borderSubtle = frozenWater100;

  // Backward-compatible semantic aliases
  static const Color canvas = bgSurface;
  static const Color canvasParchment = bgPage;
  static const Color surfacePearl = bgPage;
  static const Color ink = textPrimary;
  static const Color body = textPrimary;
  static const Color inkMuted80 = textSecondary;
  static const Color inkMuted48 = Color(0xFF8A9491);
  static const Color bodyOnDark = Color(0xFFFFFFFF);
  static const Color bodyMuted = textSecondary;
  static const Color hairline = border;
  static const Color cardBorder = border;
  static const Color dividerSoft = Color(0xFFF0F4F3);

  static const Color surfaceBlack = darkAmethyst950;
  static const Color surfaceTile1 = darkAmethyst900;
  static const Color surfaceTile2 = darkAmethyst800;
  static const Color surfaceTile3 = darkAmethyst950;
  static const Color surfaceChipTranslucent = Color(0xA3BCAFE9);

  static const Color tertiary = darkAmethyst500;
  static const Color tertiaryContainer = darkAmethyst100;
  static const Color onTertiaryContainer = darkAmethyst900;

  static const Color water = frozenWater500;
  static const Color waterText = frozenWater700;

  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFD84B4B);
  static const Color onError = Color(0xFFFFFFFF);

  /// ColorScheme resmi Flutter light mode sesuai design.md
  static ColorScheme lightColorScheme() {
    return const ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: Colors.white,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: aiAccent,
      onTertiary: onAi,
      tertiaryContainer: darkAmethyst100,
      onTertiaryContainer: darkAmethyst900,
      surface: bgSurface,
      onSurface: textPrimary,
      surfaceContainerLow: bgPage,
      surfaceContainerHighest: bgPage,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: borderSubtle,
      inverseSurface: surfaceBlack,
      onInverseSurface: bodyOnDark,
      error: error,
      onError: onError,
    );
  }
}
