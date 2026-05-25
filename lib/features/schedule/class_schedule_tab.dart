import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/constants/constants.dart';

/// Weekly class timetable from Firestore `schedules` (admin-deployed).
class ClassScheduleTab extends ConsumerWidget {
  const ClassScheduleTab({super.key});

  static const _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    final scheduleAsync = ref.watch(scheduleProvider);

    if (userProfile?.cohort == null || userProfile!.cohort!.trim().isEmpty) {
      return EmptyState(
        icon: Icons.school_outlined,
        title: 'Class Allocation Not Selected',
        subtitle: 'Select your section and group in your profile to view your class timetable.',
        actionLabel: 'Set Section & Group',
        onAction: () => context.go('/profile'),
      );
    }

    return scheduleAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const CardSkeleton(),
      ),
      error: (e, _) => ErrorState(message: e.toString()),
      data: (items) {
        final classes = items.where((s) => s.type == ScheduleType.classType).toList();

        if (classes.isEmpty) {
          return const EmptyState(
            icon: Icons.calendar_view_week_rounded,
            title: 'No Class Schedule',
            subtitle: 'Your cohort timetable has not been published yet.',
          );
        }

        final byDay = <int, List<ScheduleItem>>{};
        for (final item in classes) {
          byDay.putIfAbsent(item.dayIndex, () => []).add(item);
        }

        final sortedDays = byDay.keys.toList()..sort();

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: sortedDays.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final dayIndex = sortedDays[index];
            final dayItems = byDay[dayIndex]!..sort((a, b) => a.startTime.compareTo(b.startTime));
            final dayLabel = dayIndex >= 0 && dayIndex < _dayNames.length
                ? _dayNames[dayIndex]
                : 'Day ${dayIndex + 1}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(dayLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
                const SizedBox(height: 10),
                ...dayItems.map((item) => _ClassCard(item: item)),
              ],
            );
          },
        );
      },
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.item});
  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final hasStatus = item.statusMessage != null &&
        item.statusMessage!.isNotEmpty &&
        (item.statusExpiresAt == null || item.statusExpiresAt!.isAfter(DateTime.now()));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.subject, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          _Row(icon: Icons.access_time_rounded, text: '${item.startTime} – ${item.endTime}'),
          _Row(icon: Icons.meeting_room_outlined, text: item.room.isNotEmpty ? item.room : 'Room TBA'),
          if (item.instructor.isNotEmpty)
            _Row(icon: Icons.person_outline_rounded, text: item.instructor),
          if (hasStatus) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: Colors.amber.shade800),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.statusMessage!,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }
}
