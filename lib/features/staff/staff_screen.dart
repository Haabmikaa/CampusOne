import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/widgets/widgets.dart';

class StaffScreen extends ConsumerWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.badge_rounded, color: AppColors.neutral0, size: 18),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('Staff Portal', style: AppTypography.titleMedium.copyWith(color: cs.primary, fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: userAsync.when(
              data: (user) => CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer,
                child: Text(user?.initials ?? '?', style: AppTypography.labelSmall.copyWith(color: cs.primary)),
              ),
              loading: () => const CircleAvatar(radius: 18, child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const CircleAvatar(radius: 18, child: Icon(Icons.person)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentUserProvider);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userAsync.when(
                  data: (user) => _StaffHeroCard(
                    name: user?.name ?? 'Staff Member',
                    role: user?.department ?? 'Staff',
                    date: DateFormat('EEEE, MMM d').format(now),
                  ),
                  loading: () => const CardSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                Text('Staff Workspace', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                
                // Staff Actions Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.1,
                  children: [
                    _StaffActionCard(
                      title: 'My Schedule',
                      subtitle: 'View teaching hours',
                      icon: Icons.calendar_month_rounded,
                      color: AppColors.primary600,
                      onTap: () => context.push(AppRoutes.schedule),
                    ),
                    _StaffActionCard(
                      title: 'Student Complaints',
                      subtitle: 'Review & resolve',
                      icon: Icons.feedback_rounded,
                      color: AppColors.error,
                      onTap: () => context.push(AppRoutes.complaints),
                    ),
                    _StaffActionCard(
                      title: 'Announcements',
                      subtitle: 'Post new notices',
                      icon: Icons.campaign_rounded,
                      color: AppColors.secondary500,
                      onTap: () => context.push(AppRoutes.announcements),
                    ),
                    _StaffActionCard(
                      title: 'Campus Map',
                      subtitle: 'Navigate ASTU',
                      icon: Icons.map_rounded,
                      color: AppColors.accent500,
                      onTap: () => context.push(AppRoutes.map),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.xl),
                Text('Recent Activity', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: Text(
                        'No recent activity to display.',
                        style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'staff_fab',
        onPressed: () {},
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff'),
      ),
    );
  }
}

class _StaffHeroCard extends StatelessWidget {
  const _StaffHeroCard({required this.name, required this.role, required this.date});
  final String name, role, date;

  @override
  Widget build(BuildContext context) {
    return AppGradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome to ASTU', style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral0.withAlpha(200))),
                  const SizedBox(height: 2),
                  Text(name, style: AppTypography.greeting.copyWith(color: AppColors.neutral0)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.neutral0.withAlpha(30), borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                    child: Text(role, style: AppTypography.labelSmall.copyWith(color: AppColors.neutral0)),
                  ),
                ],
              ),
              const Icon(Icons.badge_rounded, color: AppColors.neutral0, size: 40),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.neutral0.withAlpha(40)),
          const SizedBox(height: AppSpacing.xs),
          Text(date, style: AppTypography.labelMedium.copyWith(color: AppColors.neutral0.withAlpha(220))),
        ],
      ),
    );
  }
}

class _StaffActionCard extends StatelessWidget {
  const _StaffActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: AppTypography.titleSmall),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
