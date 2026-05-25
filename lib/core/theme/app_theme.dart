import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';

/// CampusOne App Theme
/// Material Design 3 compliant with custom color seed
class AppTheme {
  AppTheme._();

  // ─── Seed Color ───────────────────────────────────────────
  static const Color _seedColor = AppColors.primary600;

  // ══════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════
  static ThemeData get light {
    final cs = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      primary: AppColors.primary600,
      onPrimary: AppColors.neutral0,
      primaryContainer: AppColors.primary100,
      onPrimaryContainer: AppColors.primary800,
      secondary: AppColors.secondary500,
      onSecondary: AppColors.neutral0,
      secondaryContainer: AppColors.secondary50,
      onSecondaryContainer: AppColors.secondary700,
      tertiary: AppColors.accent500,
      onTertiary: AppColors.neutral0,
      tertiaryContainer: AppColors.accent100,
      onTertiaryContainer: AppColors.accent600,
      error: AppColors.error,
      onError: AppColors.neutral0,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.onSurfaceLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
      outline: AppColors.outlineLight,
      outlineVariant: AppColors.outlineVariantLight,
      surfaceContainerHighest: AppColors.surfaceElevated2Light,
      surfaceContainerHigh: AppColors.surfaceElevated1Light,
    );

    return _buildTheme(cs, Brightness.light);
  }

  // ══════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════
  static ThemeData get dark {
    final cs = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      primary: AppColors.primary200,
      onPrimary: AppColors.primary800,
      primaryContainer: AppColors.primary700,
      onPrimaryContainer: AppColors.primary100,
      secondary: AppColors.secondary200,
      onSecondary: AppColors.secondary700,
      secondaryContainer: AppColors.secondary600,
      onSecondaryContainer: AppColors.secondary50,
      tertiary: AppColors.accentLight,
      onTertiary: AppColors.accent600,
      tertiaryContainer: AppColors.accent600,
      onTertiaryContainer: AppColors.accent100,
      error: AppColors.errorLight,
      onError: AppColors.neutral950,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.onSurfaceDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
      outline: AppColors.outlineDark,
      outlineVariant: AppColors.outlineVariantDark,
      surfaceContainerHighest: AppColors.surfaceElevated2Dark,
      surfaceContainerHigh: AppColors.surfaceElevated1Dark,
    );

    return _buildTheme(cs, Brightness.dark);
  }

  // ─── Shared Theme Builder ─────────────────────────────────
  static ThemeData _buildTheme(ColorScheme cs, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      brightness: brightness,
      fontFamily: AppTypography.fontFamily,

      // ── App Bar ───────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: cs.surface,
        ),
      ),

      // ── Bottom Navigation ─────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTypography.labelMedium.copyWith(
            color: selected ? cs.primary : cs.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? cs.primary : cs.onSurfaceVariant,
            size: AppSpacing.bottomNavIconSize,
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: AppSpacing.bottomNavHeight,
      ),

      // ── Card ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: isDark
            ? AppColors.surfaceElevated1Dark
            : AppColors.surfaceElevated1Light,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: isDark
                ? AppColors.outlineDark
                : AppColors.outlineVariantLight,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input Decoration ──────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.surfaceElevated1Dark : AppColors.neutral100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.outlineDark : AppColors.outlineLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium
            .copyWith(color: cs.onSurfaceVariant),
        hintStyle:
            AppTypography.hintText.copyWith(color: cs.onSurfaceVariant),
        errorStyle:
            AppTypography.bodySmall.copyWith(color: cs.error),
      ),

      // ── Elevated Button ───────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size(
              double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.buttonText,
          elevation: 0,
        ),
      ),

      // ── Outlined Button ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(
              double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          side: BorderSide(color: cs.primary),
          textStyle: AppTypography.buttonText,
        ),
      ),

      // ── Text Button ───────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: AppTypography.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
        ),
      ),

      // ── Floating Action Button ────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        elevation: AppSpacing.elevation3,
      ),

      // ── Chip ──────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        selectedColor: cs.primaryContainer,
        labelStyle: AppTypography.chipLabel,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.micro,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        side: BorderSide.none,
      ),

      // ── Divider ───────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color:
            isDark ? AppColors.outlineDark : AppColors.outlineVariantLight,
        thickness: 1,
        space: 1,
      ),

      // ── Dialog ────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceElevated2Dark
            : AppColors.surfaceElevated1Light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        titleTextStyle:
            AppTypography.titleLarge.copyWith(color: cs.onSurface),
        contentTextStyle:
            AppTypography.bodyLarge.copyWith(color: cs.onSurfaceVariant),
      ),

      // ── Bottom Sheet ──────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceElevated1Dark
            : AppColors.surfaceElevated1Light,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        elevation: 0,
        showDragHandle: true,
      ),

      // ── Snack Bar ─────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? AppColors.neutral800 : AppColors.neutral900,
        contentTextStyle:
            AppTypography.bodyMedium.copyWith(color: AppColors.neutral0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── List Tile ─────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.micro,
        ),
        titleTextStyle:
            AppTypography.titleSmall.copyWith(color: cs.onSurface),
        subtitleTextStyle:
            AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
        minLeadingWidth: AppSpacing.minTouchTarget,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      // ── Switch ────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? cs.primary
                : cs.onSurfaceVariant),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? cs.primaryContainer
                : cs.surfaceContainerHighest),
      ),

      // ── Progress Indicator ────────────────────────────────
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: cs.primary),

      // ── Scaffold ──────────────────────────────────────────
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,

      // ── Text ──────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
    );
  }
}
