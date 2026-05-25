import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/widgets/widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
    final state = ref.read(authNotifierProvider);
    if (state is AsyncError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;

    return Scaffold(
      body: Column(
        children: [
          ClipPath(clipper: WaveClipper(), child: Container(
            height: 280,
            width: double.infinity, decoration: BoxDecoration(gradient: AppColors.heroGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.school_rounded, color: AppColors.neutral0, size: 26),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('CampusOne', style: AppTypography.titleLarge.copyWith(color: AppColors.neutral0, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Welcome back 👋', style: AppTypography.headlineSmall.copyWith(color: AppColors.neutral0)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Sign in to your campus account', style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral0.withValues(alpha: 0.8))),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: AppSpacing.md),

                // ── Email ───────────────────────────────
                AppTextField(
                  label: 'Email Address',
                  hint: 'student@university.edu',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Password ────────────────────────────
                AppTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  onSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xs),

                // ── Forgot password ─────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPw),
                    child: Text('Forgot Password?',
                        style: AppTypography.labelMedium
                            .copyWith(color: cs.primary)),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Sign in button ──────────────────────
                AppPrimaryButton(
                  label: 'Sign In',
                  onPressed: _submit,
                  isLoading: isLoading,
                  icon: Icons.login_rounded,
                ),

                const SizedBox(height: AppSpacing.lg),

                const LabeledDivider(label: 'or continue with'),

                const SizedBox(height: AppSpacing.lg),

                // ── Google sign in ──────────────────────
                AppSecondaryButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
                    final state = ref.read(authNotifierProvider);
                    if (state is AsyncError && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error.toString()),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Register link ───────────────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Don't have an account?",
                          style: AppTypography.bodySmall
                              .copyWith(color: cs.onSurfaceVariant)),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.register),
                        child: Text('Register',
                            style: AppTypography.labelMedium
                                .copyWith(color: cs.primary)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
