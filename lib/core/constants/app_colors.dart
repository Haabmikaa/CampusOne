import 'package:flutter/material.dart';

/// CampusOne Design System — Color Tokens
/// Follows Material Design 3 + 60-30-10 color rule
/// All contrast ratios meet WCAG AA (≥4.5:1)
abstract class AppColors {
  // ─── Primary Brand (Deep Blue) ───────────────────────────
  static const Color primary50 = Color(0xFFE3F2FD);
  static const Color primary100 = Color(0xFFBBDEFB);
  static const Color primary200 = Color(0xFF90CAF9);
  static const Color primary300 = Color(0xFF64B5F6);
  static const Color primary400 = Color(0xFF42A5F5);
  static const Color primary500 = Color(0xFF1E88E5); // main light
  static const Color primary600 = Color(0xFF1565C0); // main dark
  static const Color primary700 = Color(0xFF0D47A1);
  static const Color primary800 = Color(0xFF0A3880);
  static const Color primary900 = Color(0xFF072C6B);

  // ─── Secondary (Teal) ────────────────────────────────────
  static const Color secondary50 = Color(0xFFE0F2F1);
  static const Color secondary100 = Color(0xFFB2DFDB);
  static const Color secondary200 = Color(0xFF80CBC4);
  static const Color secondary300 = Color(0xFF4DB6AC);
  static const Color secondary400 = Color(0xFF26A69A);
  static const Color secondary500 = Color(0xFF00897B); // main
  static const Color secondary600 = Color(0xFF00796B);
  static const Color secondary700 = Color(0xFF00695C);

  // ─── Accent / Tertiary (Amber) ───────────────────────────
  static const Color accent100 = Color(0xFFFFF8E1);
  static const Color accent300 = Color(0xFFFFD54F);
  static const Color accent500 = Color(0xFFFF6F00); // main
  static const Color accent600 = Color(0xFFE65100);
  static const Color accentLight = Color(0xFFFFB300);

  // ─── Neutrals ────────────────────────────────────────────
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFF8FAFF);
  static const Color neutral100 = Color(0xFFEEF2FF);
  static const Color neutral200 = Color(0xFFE0E7FF);
  static const Color neutral300 = Color(0xFFC7D2FE);
  static const Color neutral400 = Color(0xFFA5B4FC);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);
  static const Color neutral950 = Color(0xFF070D14);

  // ─── Semantic Status Colors ───────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color successSurface = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFB300);
  static const Color warningSurface = Color(0xFFFFF8E1);

  static const Color error = Color(0xFFB00020);
  static const Color errorLight = Color(0xFFCF6679);
  static const Color errorSurface = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFF29B6F6);
  static const Color infoSurface = Color(0xFFE1F5FE);

  // ─── Surface Tiers (Light Theme) ─────────────────────────
  static const Color surfaceLight = Color(0xFFF8FAFF);
  static const Color surfaceElevated1Light = Color(0xFFFFFFFF);
  static const Color surfaceElevated2Light = Color(0xFFF0F4FF);
  static const Color backgroundLight = Color(0xFFEEF2FF);
  static const Color onSurfaceLight = Color(0xFF1F2937);
  static const Color onSurfaceVariantLight = Color(0xFF4B5563);
  static const Color outlineLight = Color(0xFFD1D5DB);
  static const Color outlineVariantLight = Color(0xFFE5E7EB);

  // ─── Surface Tiers (Dark Theme) ──────────────────────────
  static const Color surfaceDark = Color(0xFF0F1923);
  static const Color surfaceElevated1Dark = Color(0xFF162030);
  static const Color surfaceElevated2Dark = Color(0xFF1E2D3D);
  static const Color backgroundDark = Color(0xFF070D14);
  static const Color onSurfaceDark = Color(0xFFE5E7EB);
  static const Color onSurfaceVariantDark = Color(0xFF9CA3AF);
  static const Color outlineDark = Color(0xFF374151);
  static const Color outlineVariantDark = Color(0xFF1F2937);

  // ─── Glassmorphism ───────────────────────────────────────
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassBorderLight = Color(0x40FFFFFF);
  static const Color glassBorderDark = Color(0x1AFFFFFF);

  // ─── Gradients ───────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary600, primary800],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF0D47A1), Color(0xFF072C6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent500, accent600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
