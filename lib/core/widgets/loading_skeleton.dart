import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Shimmer loading skeleton for list items
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? borderRadius;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF1E2D3D) : const Color(0xFFE8EAF6);
    final shineColor =
        isDark ? const Color(0xFF2A3E52) : const Color(0xFFF5F5FF);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppSpacing.radiusSm),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: [baseColor, shineColor, baseColor],
          ),
        ),
      ),
    );
  }
}

/// Card-level skeleton (title + 2 lines + icon)
class CardSkeleton extends StatelessWidget {
  const CardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceElevated1Dark
            : AppColors.surfaceElevated1Light,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outlineVariantLight,
        ),
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              const LoadingSkeleton(width: 40, height: 40, borderRadius: 20),
              const SizedBox(width: AppSpacing.sm),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const LoadingSkeleton(width: 120, height: 14),
                const SizedBox(height: AppSpacing.micro),
                LoadingSkeleton(
                    width: 80, height: 11, borderRadius: AppSpacing.radiusXs),
              ]),
            ]),
            const SizedBox(height: AppSpacing.sm),
            const LoadingSkeleton(width: double.infinity, height: 12),
            const SizedBox(height: AppSpacing.micro),
            const LoadingSkeleton(width: 200, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Compact skeleton for stats tiles (row of 3)
class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.surfaceElevated1Dark : AppColors.surfaceElevated1Light;
    
    return Row(
      children: List.generate(3, (index) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingSkeleton(width: 20, height: 20, borderRadius: 6),
              SizedBox(height: 8),
              LoadingSkeleton(width: 30, height: 18),
              SizedBox(height: 4),
              LoadingSkeleton(width: 50, height: 10),
            ],
          ),
        ),
      )),
    );
  }
}
