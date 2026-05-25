import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/data_provider.dart';
import '../../core/models/complaint_model.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(complaintsProvider);
    final announcementsAsync = ref.watch(announcementsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Stats', style: AppTypography.titleMedium.copyWith(color: cs.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  label: 'Pending', 
                  value: complaintsAsync.maybeWhen(
                    data: (items) => '${items.where((c) => c.status == ComplaintStatus.pending).length}',
                    orElse: () => '...'
                  ), 
                  icon: Icons.pending_actions_rounded, 
                  color: AppColors.secondary500,
                ),
                _StatCard(
                  label: 'Resolved', 
                  value: complaintsAsync.maybeWhen(
                    data: (items) => '${items.where((c) => c.status == ComplaintStatus.resolved).length}',
                    orElse: () => '...'
                  ), 
                  icon: Icons.check_circle_rounded, 
                  color: AppColors.success,
                ),
                _StatCard(
                  label: 'Notices', 
                  value: announcementsAsync.maybeWhen(
                    data: (items) => '${items.length}',
                    orElse: () => '...'
                  ), 
                  icon: Icons.campaign_rounded, 
                  color: cs.primary,
                ),
                const _StatCard(
                  label: 'Active Users', 
                  value: '1.2k', 
                  icon: Icons.people_rounded, 
                  color: AppColors.accent500,
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Recent Activity'),
            const SizedBox(height: AppSpacing.sm),
            
            complaintsAsync.when(
              data: (items) {
                final recent = items.take(5).toList();
                if (recent.isEmpty) return const Center(child: Text('No complaints yet'));
                return Column(
                  children: recent.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: AppCard(
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.title, style: AppTypography.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(c.category, style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant)),
                        ])),
                        const SizedBox(width: AppSpacing.sm),
                        StatusChip(status: c.status.name),
                      ]),
                    ),
                  )).toList(),
                );
              },
              loading: () => const LoadingSkeleton(width: double.infinity, height: 100),
              error: (e, _) => Text('Error: $e'),
            ),

            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              label: 'Post Announcement',
              onPressed: () {},
              icon: Icons.add_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: AppTypography.labelSmall.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
