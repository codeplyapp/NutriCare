import 'package:flutter/material.dart';

/// Sistem token animasi NutriCare sesuai spesifikasi DESIGN.md & LIB_THEME.md
class AppMotion {
  // Durasi animasi token
  static const Duration micro = Duration(milliseconds: 150);  // Tombol press, icon tab
  static const Duration base = Duration(milliseconds: 250);   // Indikator dock, back button
  static const Duration page = Duration(milliseconds: 300);   // Transisi halaman/route, step onboarding
  static const Duration sweep = Duration(milliseconds: 700);  // Donut chart sweep, evaluasi meter BMI
  static const Duration pulse = Duration(milliseconds: 1200); // Radar IoT, gelombang audio call RTC

  // Aliases for compatibility
  static const Duration durationMicro = micro;
  static const Duration durationBase = base;
  static const Duration durationPage = page;
  static const Duration durationSweep = sweep;
  static const Duration durationPulse = pulse;

  // Kurva animasi token
  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveEmphasis = Curves.easeOutCubic;
  static const Curve curveDecelerate = Curves.fastOutSlowIn;

  /// Membaca preferensi aksesibilitas pengguna (Reduced Motion)
  /// Mengembalikan [Duration.zero] bila reduced-motion aktif di OS/perangkat.
  static Duration resolve(BuildContext context, Duration defaultDuration) {
    final disable = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return disable ? Duration.zero : defaultDuration;
  }
}
