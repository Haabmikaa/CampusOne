/// CampusOne Design System — Spacing Tokens
/// Strict 8dp grid system for consistent layout rhythm
abstract class AppSpacing {
  // ─── Base Grid ────────────────────────────────────────────
  static const double micro = 4.0;     // micro gaps
  static const double xs = 8.0;       // tight spacing
  static const double sm = 12.0;      // compact elements
  static const double md = 16.0;      // standard padding
  static const double lg = 24.0;      // section spacing
  static const double xl = 32.0;      // major separation
  static const double xxl = 48.0;     // hero sections
  static const double xxxl = 64.0;    // full-screen sections

  // ─── Semantic Aliases ─────────────────────────────────────
  static const double cardPadding = md;
  static const double screenPadding = md;
  static const double itemSpacing = xs;
  static const double sectionSpacing = lg;
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double chipHeight = 36.0;
  static const double fabSize = 56.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 72.0;
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double minTouchTarget = 48.0; // WCAG min

  // ─── Border Radius ─────────────────────────────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 999.0;

  // ─── Elevation ─────────────────────────────────────────────
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 3.0;
  static const double elevation3 = 6.0;
  static const double elevation4 = 12.0;
  static const double elevation5 = 24.0;

  // ─── Bottom Nav ───────────────────────────────────────────
  static const double bottomNavHeight = 72.0;
  static const double bottomNavIconSize = 24.0;

  // ─── App Bar ──────────────────────────────────────────────
  static const double appBarHeight = 64.0;

  // ─── Card Constraints ─────────────────────────────────────
  static const double cardMaxWidth = 600.0;
}
