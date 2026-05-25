import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/data_provider.dart';
import '../../core/models/complaint_model.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/models/user_model.dart';

class ComplaintDetailScreen extends ConsumerWidget {
  const ComplaintDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintAsync = ref.watch(complaintDetailProvider(id));
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Details')),
      body: complaintAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (complaint) {
          if (complaint == null) return const EmptyState(icon: Icons.error_outline, title: 'Not Found');
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Complaint #${complaint.id.substring(0, 8)}', style: AppTypography.titleSmall.copyWith(color: cs.onSurfaceVariant)),
                          StatusChip(status: complaint.status.value),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(complaint.title, style: AppTypography.titleMedium.copyWith(color: cs.onSurface)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('${complaint.category} • Submitted ${_formatDate(complaint.createdAt)}', style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                
                if (userProfile != null && userProfile.role == UserRole.staff) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Staff Actions', style: AppTypography.titleSmall.copyWith(color: cs.onSurface)),
                        const SizedBox(height: AppSpacing.sm),
                        DropdownButtonFormField<ComplaintStatus>(
                          isExpanded: true,
                          isDense: true,
                          value: complaint.status,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
                          ),
                          items: ComplaintStatus.values.map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(
                              status.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              ref.read(dataServiceProvider).updateComplaintStatus(complaint.id, newStatus);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated successfully!')));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.md),
                Text('Description', style: AppTypography.titleSmall.copyWith(color: cs.onSurface)),
                const SizedBox(height: AppSpacing.xs),
                Text(complaint.description, style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant, height: 1.6)),
                const SizedBox(height: AppSpacing.lg),
                
                if (complaint.mediaUrls.isNotEmpty) ...[
                  Text('Attachments', style: AppTypography.titleSmall.copyWith(color: cs.onSurface)),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: complaint.mediaUrls.length,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: Image.network(complaint.mediaUrls[i], width: 100, height: 100, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                Text('Status Timeline', style: AppTypography.titleSmall.copyWith(color: cs.onSurface)),
                const SizedBox(height: AppSpacing.sm),
                _TimelineItem(
                  icon: Icons.check_circle_rounded, 
                  color: AppColors.success, 
                  title: 'Submitted', 
                  subtitle: _formatDate(complaint.createdAt), 
                  isLast: complaint.status == ComplaintStatus.pending
                ),
                if (complaint.status != ComplaintStatus.pending)
                  _TimelineItem(
                    icon: Icons.search_rounded, 
                    color: AppColors.info, 
                    title: complaint.status.displayName, 
                    subtitle: _formatDate(complaint.updatedAt), 
                    isLast: true
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }
}


class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.icon, required this.color, required this.title, required this.subtitle, required this.isLast});
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color)),
          if (!isLast) Container(width: 2, height: 32, color: cs.outlineVariant),
        ]),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTypography.titleSmall.copyWith(color: cs.onSurface)),
            Text(subtitle, style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
          ]),
        )),
      ],
    );
  }
}
