import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Base card container with consistent styling
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
    this.hasBorder = true,
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final bool hasBorder;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);
    final bgColor = color ??
        (isDark
            ? AppColors.surfaceElevated1Dark
            : AppColors.surfaceElevated1Light);

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: hasBorder
            ? Border.all(
                color: isDark
                    ? AppColors.outlineDark
                    : AppColors.outlineVariantLight,
                width: 1,
              )
            : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: cs.shadow.withAlpha(20),
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation * 0.5),
                )
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      );
    }

    return margin != null ? Padding(padding: margin!, child: content) : content;
  }
}

/// Gradient hero card (used on dashboard)
class AppGradientCard extends StatelessWidget {
  const AppGradientCard({
    super.key,
    required this.child,
    this.gradient = AppColors.heroGradient,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final LinearGradient gradient;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}
