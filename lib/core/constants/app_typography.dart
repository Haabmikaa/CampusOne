import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CampusOne Design System — Typography Tokens
/// Uses Google Fonts Inter — loaded at runtime, no asset files needed
abstract class AppTypography {
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  // ─── Display ──────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w400, height: 1.12, letterSpacing: -0.25);
  static TextStyle get displayMedium => GoogleFonts.inter(fontSize: 45, fontWeight: FontWeight.w400, height: 1.16);
  static TextStyle get displaySmall => GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w400, height: 1.22);

  // ─── Headline ─────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, height: 1.25);
  static TextStyle get headlineMedium => GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, height: 1.29);
  static TextStyle get headlineSmall => GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, height: 1.33);

  // ─── Title ────────────────────────────────────────────────
  static TextStyle get titleLarge => GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w600, height: 1.27);
  static TextStyle get titleMedium => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5, letterSpacing: 0.15);
  static TextStyle get titleSmall => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, height: 1.43, letterSpacing: 0.1);

  // ─── Body ─────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.5);
  static TextStyle get bodyMedium => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.25);
  static TextStyle get bodySmall => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5, letterSpacing: 0.4);

  // ─── Label ────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, height: 1.43, letterSpacing: 0.1);
  static TextStyle get labelMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, height: 1.33, letterSpacing: 0.5);
  static TextStyle get labelSmall => GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, height: 1.45, letterSpacing: 0.5);

  // ─── Semantic Aliases ─────────────────────────────────────
  static TextStyle get greeting => GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, height: 1.3);
  static TextStyle get cardTitle => titleMedium;
  static TextStyle get sectionHeader => titleLarge;
  static TextStyle get chipLabel => labelMedium;
  static TextStyle get buttonText => labelLarge;
  static TextStyle get caption => labelSmall;
  static TextStyle get inputText => bodyLarge;
  static TextStyle get hintText => bodyMedium;
}
