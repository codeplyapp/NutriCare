import 'package:flutter/material.dart';

/// Konstanta Radius & Shape resmi NutriCare sesuai design.md v1.0
class AppShapes {
  /// 0px - Tile full-bleed
  static const double radiusNone = 0.0;

  /// 8px - Chip kecil, elemen kompak
  static const double radiusXs = 8.0;

  /// 12px - Input field, sub-card
  static const double radiusSm = 12.0;
  static const double radiusInput = 12.0;

  /// 14px - Tombol resmi design.md
  static const double radiusBtn = 14.0;
  static const double radiusMd = 14.0;

  /// 16px - Kartu fitur / dashboard
  static const double radiusCard = 16.0;
  static const double radiusLg = 16.0;

  /// 24px - Modal / Bottom sheet
  static const double radiusModal = 24.0;
  static const double radiusXl = 24.0;

  /// 9999px - Pill / chip bulat
  static const double radiusPill = 9999.0;

  // BorderRadius instances
  static BorderRadius get none => BorderRadius.zero;
  static BorderRadius get xs => BorderRadius.circular(radiusXs);
  static BorderRadius get sm => BorderRadius.circular(radiusSm);
  static BorderRadius get input => BorderRadius.circular(radiusInput);
  static BorderRadius get btn => BorderRadius.circular(radiusBtn);
  static BorderRadius get md => BorderRadius.circular(radiusMd);
  static BorderRadius get card => BorderRadius.circular(radiusCard);
  static BorderRadius get lg => BorderRadius.circular(radiusLg);
  static BorderRadius get modal => const BorderRadius.vertical(top: Radius.circular(radiusModal));
  static BorderRadius get pill => BorderRadius.circular(radiusPill);

  // ShapeBorder helpers for buttons & cards
  static OutlinedBorder pillShape({BorderSide side = BorderSide.none}) =>
      RoundedRectangleBorder(borderRadius: pill, side: side);

  static OutlinedBorder inputShape({BorderSide side = BorderSide.none}) =>
      RoundedRectangleBorder(borderRadius: input, side: side);

  static OutlinedBorder buttonShape({BorderSide side = BorderSide.none}) =>
      RoundedRectangleBorder(borderRadius: btn, side: side);

  static OutlinedBorder cardShape({BorderSide side = BorderSide.none}) =>
      RoundedRectangleBorder(borderRadius: card, side: side);

  static OutlinedBorder smShape({BorderSide side = BorderSide.none}) =>
      RoundedRectangleBorder(borderRadius: sm, side: side);

  static OutlinedBorder mdShape({BorderSide side = BorderSide.none}) =>
      RoundedRectangleBorder(borderRadius: md, side: side);

  // Soft elevation shadow from design.md (0 4px 12px rgba(0,0,0,0.06))
  static const List<BoxShadow> softElevation = [
    BoxShadow(
      color: Color(0x0F000000), // rgba(0,0,0,0.06)
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
