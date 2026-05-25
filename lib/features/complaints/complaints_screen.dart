import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/data_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/routing/app_router.dart';

class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(complaintsProvider);
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    final isStaff = userProfile?.role == UserRole.staff;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          isStaff ? 'My Assigned Tasks' : 'My Complaints',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          // Removed New Complaint from AppBar to place in FAB per user request
        ],
      ),
      floatingActionButton: isStaff || (complaintsAsync.valueOrNull?.isEmpty ?? true)
          ? null
          : Container(
              margin: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton(
                onPressed: () => context.push('/complaints/new'),
                elevation: 4,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: const Icon(Icons.add),
              ),
            ),
      body: complaintsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, __) => const CardSkeleton(),
        ),
        error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(complaintsProvider)),
        data: (complaints) {
          if (complaints.isEmpty) {
            return EmptyState(
              icon: isStaff ? Icons.task_alt : Icons.feedback_outlined,
              title: isStaff ? 'No Tasks Assigned' : 'No Complaints Yet',
              subtitle: isStaff
                  ? 'You have no complaints assigned to you yet.'
                  : 'Submit a complaint to get started.',
              actionLabel: isStaff ? '' : 'New Complaint',
              onAction: isStaff ? null : () => context.push('/complaints/new'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              AppSpacing.screenPadding,
              100, // Prevent content hiding behind bottom nav
            ),
            itemCount: complaints.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) {
              final complaint = complaints[i];
              return AppCard(
                onTap: () => context.push('/complaints/${complaint.id}'),
                child: Row(children: [
                  // Status indicator strip
                  Container(
                    width: 4, height: 48,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _statusColor(complaint.status.value),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(complaint.title, style: AppTypography.titleSmall.copyWith(color: cs.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Icon(Icons.category_outlined, size: 13, color: cs.onSurfaceVariant),
                        Text(complaint.category, style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(width: AppSpacing.sm - 4),
                        Icon(Icons.schedule_outlined, size: 13, color: cs.onSurfaceVariant),
                        Text(_formatDate(complaint.createdAt), style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ])),
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(status: complaint.status.value),
                ]),
              );
            },
          );
        },
      ),
      // No FAB for staff — it causes crowding with the AI FAB in the shell
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved': return const Color(0xFF10B981);
      case 'in_review': return const Color(0xFFF59E0B);
      case 'closed': return const Color(0xFF64748B);
      default: return const Color(0xFFEF4444);
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
