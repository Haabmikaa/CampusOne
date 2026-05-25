import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordReset(_emailCtrl.text.trim());

    final authState = ref.read(authNotifierProvider);
    if (authState is AsyncError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(authState.error.toString()),
            backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLoading = ref.watch(authNotifierProvider) is AsyncLoading;

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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.lock_reset_rounded, size: 32, color: AppColors.neutral0),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Forgot your password?', style: AppTypography.headlineSmall.copyWith(color: AppColors.neutral0)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Enter your registered email and we\'ll send you a link to reset your password.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral0.withValues(alpha: 0.8), height: 1.4),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: _emailSent ? _SuccessView(email: _emailCtrl.text.trim()) : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: 'Email Address',
                      hint: 'student@university.edu',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.email_outlined),
                      onSubmitted: (_) => _submit(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    AppPrimaryButton(
                      label: 'Send Reset Link',
                      onPressed: _submit,
                      isLoading: isLoading,
                      icon: Icons.send_rounded,
                    ),
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

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.successSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_rounded,
                size: 48, color: AppColors.success),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Check your inbox!',
              style: AppTypography.titleLarge.copyWith(color: cs.onSurface)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'We sent a password reset link to\n$email',
            style: AppTypography.bodyMedium
                .copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'Back to Sign In',
            onPressed: () => context.pop(),
            icon: Icons.arrow_back_rounded,
            width: 220,
          ),
        ],
      ),
    );
  }
}
