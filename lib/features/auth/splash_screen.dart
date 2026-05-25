import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routing/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _runAnimations();
  }

  Future<void> _runAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _navigate();
  }

  Future<void> _navigate() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      if (mounted) context.go(AppRoutes.home);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;
      if (hasSeen) {
        if (mounted) context.go(AppRoutes.login);
      } else {
        await prefs.setBool('has_seen_onboarding', true);
        if (mounted) context.go(AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated logo ──────────────────────
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.glassLight,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXl),
                      border:
                          Border.all(color: AppColors.glassBorderLight, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 52,
                      color: AppColors.neutral0,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Animated text ──────────────────────
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, child) => FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                        position: _textSlide, child: child),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CampusOne',
                        style: AppTypography.headlineLarge.copyWith(
                          color: AppColors.neutral0,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Your Smart Campus Companion',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.neutral0.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // ── Loading indicator ──────────────────
                SizedBox(
                  width: 140,
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.neutral0.withAlpha(40),
                    color: AppColors.neutral0,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
