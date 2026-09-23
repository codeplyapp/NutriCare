import 'package:flutter/material.dart';

/// Konstanta Elevasi & Efek resmi NutriCare sesuai LIB_THEME.md & DESIGN.md
class AppShadows {
  /// Satu-satunya drop-shadow yang diizinkan dalam sistem desain NutriCare
  /// (rgba(0,0,0,0.22) 3px 5px 30px).
  /// PERINGATAN: Hanya boleh digunakan untuk imagery/mockup produk di atas permukaan.
  /// DILARANG digunakan pada kartu, tombol, atau teks.
  static const BoxShadow product = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.22),
    offset: Offset(3, 5),
    blurRadius: 30,
    spreadRadius: 0,
  );

  static const List<BoxShadow> productShadowList = [product];
}
