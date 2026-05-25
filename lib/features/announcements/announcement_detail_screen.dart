import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/data_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/widgets.dart';

class AnnouncementDetailScreen extends ConsumerWidget {
  const AnnouncementDetailScreen({super.key, required this.id});
  final String id;

  static const _catColors = {
    'Academic': Color(0xFF3B82F6),
    'Events': Color(0xFF8B5CF6),
    'Staff': Color(0xFF10B981),
    'Sports': Color(0xFFF59E0B),
    'IT': Color(0xFF0EA5E9),
    'Library': Color(0xFFF97316),
    'General': Color(0xFF6366F1),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(announcementDetailProvider(id));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (ann) {
          if (ann == null) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'Not Found',
              subtitle: 'This announcement may have been removed.',
            );
          }

          final user = ref.watch(currentUserProvider).valueOrNull;
          if (user != null && !ann.isVisibleTo(user.role)) {
            return const EmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Restricted',
              subtitle: 'This notice is not available for your account type.',
            );
          }

          final catColor = _catColors[ann.category] ?? AppColors.primary600;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: ann.hasImage ? 280 : 120,
                pinned: true,
                stretch: true,
                backgroundColor: catColor,
                foregroundColor: Colors.white,
                // Dark circle backdrop makes the back arrow visible over any image.
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const BackButton(color: Colors.white),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    ann.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  background: ann.hasImage
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            AnnouncementHeroImage(
                              imageUrl: ann.imageUrl!,
                              height: 280,
                              borderRadius: BorderRadius.zero,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.65),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [catColor, catColor.withOpacity(0.85)],
                            ),
                          ),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Icon(
                                _categoryIcon(ann.category),
                                size: 72,
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaChip(
                            label: ann.category,
                            color: catColor,
                            icon: _categoryIcon(ann.category),
                          ),
                          if (ann.isPinned)
                            const _MetaChip(
                              label: 'Pinned',
                              color: Color(0xFF3B82F6),
                              icon: Icons.push_pin_rounded,
                            ),
                          if (ann.isUrgent)
                            const _MetaChip(
                              label: 'Urgent',
                              color: Color(0xFFEF4444),
                              icon: Icons.warning_amber_rounded,
                            ),
                          _MetaChip(
                            label: _audienceLabel(ann.audience),
                            color: AppColors.neutral600,
                            icon: Icons.people_outline_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _formatPosted(ann.createdAt),
                        style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                      ),
                      if (ann.hasEventMeta) ...[
                        const SizedBox(height: AppSpacing.lg),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Event Details', style: AppTypography.titleSmall),
                              const SizedBox(height: AppSpacing.sm),
                              if (ann.eventDate != null && ann.eventDate!.isNotEmpty)
                                _DetailRow(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Date',
                                  value: _formatEventDate(ann.eventDate!, ann.eventTime),
                                ),
                              if (ann.location != null && ann.location!.isNotEmpty)
                                _DetailRow(
                                  icon: Icons.location_on_outlined,
                                  label: 'Location',
                                  value: ann.location!,
                                ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        ann.body,
                        style: AppTypography.bodyLarge.copyWith(
                          color: cs.onSurface,
                          height: 1.75,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Academic':
        return Icons.school_rounded;
      case 'Events':
        return Icons.event_rounded;
      case 'Staff':
        return Icons.engineering_rounded;
      case 'Sports':
        return Icons.sports_rounded;
      case 'IT':
        return Icons.computer_rounded;
      case 'Library':
        return Icons.menu_book_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  String _audienceLabel(String audience) {
    switch (audience) {
      case 'student':
        return 'Students';
      case 'staff':
        return 'Staff';
      default:
        return 'Everyone';
    }
  }

  String _formatPosted(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 1) return 'Posted ${DateFormat('MMM d, yyyy • h:mm a').format(d)}';
    if (diff.inHours >= 1) return 'Posted ${diff.inHours}h ago';
    return 'Posted just now';
  }

  String _formatEventDate(String date, String? time) {
    if (time != null && time.isNotEmpty) return '$date · $time';
    return date;
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color, required this.icon});
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary600),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.neutral500)),
                Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
