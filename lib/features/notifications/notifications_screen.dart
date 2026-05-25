import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import '../../core/models/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Text('Notifications'),
          notificationsAsync.when(
            data: (items) {
              final unread = items.where((n) => !n.isRead).length;
              if (unread == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xs),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                  child: Text('$unread', style: AppTypography.labelSmall.copyWith(color: cs.onPrimary)),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ]),
        actions: [
          notificationsAsync.maybeWhen(
            data: (items) => items.any((n) => !n.isRead) 
              ? TextButton(
                  onPressed: () {
                    if (user != null) {
                      ref.read(dataServiceProvider).markAllNotificationsAsRead(user.uid);
                    }
                  },
                  child: Text('Mark all read', style: AppTypography.labelMedium.copyWith(color: cs.primary)),
                )
              : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, __) => const CardSkeleton(),
        ),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (items) => items.isEmpty
            ? const EmptyState(icon: Icons.notifications_none_rounded, title: 'No Notifications', subtitle: 'You are all caught up!')
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                itemBuilder: (_, i) {
                  final n = items[i];
                  final iconData = _getIconForType(n.type);
                  final color = _getColorForType(n.type);

                  return GestureDetector(
                    onTap: () {
                      if (!n.isRead && user != null) {
                        ref.read(dataServiceProvider).markNotificationAsRead(user.uid, n.id);
                      }
                    },
                    child: AppCard(
                      color: n.isRead ? null : color.withAlpha(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: color.withAlpha(20), shape: BoxShape.circle),
                            child: Icon(iconData, color: color, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: AppTypography.titleSmall.copyWith(
                                  color: cs.onSurface, fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text(n.body, style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
                              const SizedBox(height: 4),
                              Text(_formatDate(n.createdAt), style: AppTypography.caption.copyWith(color: cs.onSurfaceVariant)),
                            ],
                          )),
                          if (!n.isRead)
                            Container(width: 8, height: 8,
                                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.complaint: return Icons.feedback_rounded;
      case NotificationType.announcement: return Icons.campaign_rounded;
      case NotificationType.broadcast: return Icons.campaign_rounded;
      case NotificationType.assignment: return Icons.assignment_rounded;
      case NotificationType.reminder: return Icons.alarm_rounded;
      case NotificationType.system: return Icons.settings_rounded;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.complaint: return AppColors.info;
      case NotificationType.announcement: return AppColors.primary600;
      case NotificationType.broadcast: return AppColors.primary600;
      case NotificationType.assignment: return const Color(0xFFF97316);
      case NotificationType.reminder: return AppColors.accent500;
      case NotificationType.system: return AppColors.secondary500;
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
