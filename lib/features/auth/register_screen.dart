import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/widgets/widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  UserRole _selectedRole = UserRole.student;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _studentIdCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.registerWithEmail(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          role: _selectedRole,
          department: null,
          studentId:
              _studentIdCtrl.text.isNotEmpty ? _studentIdCtrl.text : null,
        );
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState is AsyncError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(authState.error.toString()),
            backgroundColor: AppColors.error),
      );
    } else if (mounted) {
      context.go(AppRoutes.home);
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
                    const SizedBox(height: AppSpacing.md),
                    Text('Join CampusOne 🎓', style: AppTypography.headlineSmall.copyWith(color: AppColors.neutral0)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Fill in your details to get started', style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral0.withValues(alpha: 0.8))),
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

                // Roles are managed by admin, students register themselves
                const SizedBox(height: AppSpacing.sm),

                const SizedBox(height: AppSpacing.lg),

                // ── Full name ───────────────────────────
                AppTextField(
                  label: 'Full Name',
                  hint: 'e.g. Abebe Girma',
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Full name is required'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Email ───────────────────────────────
                AppTextField(
                  label: 'University Email',
                  hint: 'you@university.edu',
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

                AppTextField(
                  label: 'Student ID',
                  hint: 'e.g. ETS/1234/14',
                  controller: _studentIdCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Password ────────────────────────────
                AppTextField(
                  label: 'Password',
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) {
                      return 'Minimum 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Confirm password ────────────────────
                AppTextField(
                  label: 'Confirm Password',
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  onSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm password';
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                AppPrimaryButton(
                  label: 'Create Account',
                  onPressed: _submit,
                  isLoading: isLoading,
                  icon: Icons.person_add_rounded,
                ),

                const SizedBox(height: AppSpacing.lg),

                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Already have an account?',
                          style: AppTypography.bodySmall
                              .copyWith(color: cs.onSurfaceVariant)),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text('Sign In',
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
