import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/widgets/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.school_rounded,
      color: AppColors.primary600,
      title: 'Your Campus,\nAll in One Place',
      subtitle:
          'Access schedules, announcements, and campus services instantly — no more missed updates.',
    ),
    _OnboardPage(
      icon: Icons.feedback_rounded,
      color: AppColors.secondary500,
      title: 'Voice Your\nConcerns Easily',
      subtitle:
          'Submit complaints, track their status in real-time, and get notified when resolved.',
    ),
    _OnboardPage(
      icon: Icons.assistant_rounded,
      color: AppColors.accent500,
      title: 'AI-Powered\nCampus Assistant',
      subtitle:
          'Ask anything about your campus. Our smart assistant has you covered 24/7.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text('Skip',
                    style: AppTypography.labelLarge
                        .copyWith(color: cs.onSurfaceVariant)),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardPageView(page: _pages[i]),
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? cs.primary
                        : cs.onSurface.withAlpha(40),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: AppPrimaryButton(
                label: isLast ? 'Get Started' : 'Next',
                onPressed: _next,
                icon: isLast ? Icons.arrow_forward_rounded : null,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?',
                    style: AppTypography.bodySmall
                        .copyWith(color: cs.onSurfaceVariant)),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text('Sign In',
                      style: AppTypography.labelMedium
                          .copyWith(color: cs.primary)),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ─── Onboard page data ─────────────────────────────────────
class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

// ─── Single page view ──────────────────────────────────────
class _OnboardPageView extends StatelessWidget {
  const _OnboardPageView({required this.page});
  final _OnboardPage page;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: page.color.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 56, color: page.color),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            page.title,
            style: AppTypography.headlineMedium
                .copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            page.subtitle,
            style: AppTypography.bodyLarge
                .copyWith(color: cs.onSurfaceVariant, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
