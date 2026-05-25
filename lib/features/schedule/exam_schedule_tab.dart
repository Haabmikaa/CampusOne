import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/constants/constants.dart';

/// Exam timetable from Firestore `exam_schedules` (admin dashboard).
class ExamScheduleTab extends ConsumerWidget {
  const ExamScheduleTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    final scheduleAsync = ref.watch(examScheduleProvider);

    return scheduleAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const CardSkeleton(),
      ),
      error: (e, _) => ErrorState(message: e.toString()),
      data: (data) {
        if (data == null || userProfile == null) {
          return const EmptyState(
            icon: Icons.event_busy_rounded,
            title: 'No Exam Schedule',
            subtitle: 'Complete your profile or wait for admin to deploy your batch exam timetable.',
          );
        }

        if (userProfile.yearSemester == null || userProfile.yearSemester!.trim().isEmpty ||
            userProfile.studentGroup == null || userProfile.studentGroup!.trim().isEmpty) {
          return EmptyState(
            icon: Icons.badge_outlined,
            title: 'Exam Allocation Not Selected',
            subtitle: 'Select your section and group in your profile to view your exam schedule.',
            actionLabel: 'Set Section & Group',
            onAction: () => context.go('/profile'),
          );
        }

        final allocations = (data['allocations'] as List? ?? []);
        Map? myAllocation;
        for (final raw in allocations) {
          if (raw is Map && raw['group'] == userProfile.studentGroup) {
            myAllocation = raw;
            break;
          }
        }
        final examDays = (data['examDays'] as List? ?? []);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                      child: Text(userProfile.initials, style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userProfile.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                          const SizedBox(height: 4),
                          Text(userProfile.yearSemester ?? '', style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400, fontWeight: FontWeight.w600)),
                          Text('Academic Year: ${data['academicYear'] ?? '—'}', style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade300)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.meeting_room_outlined,
                      title: 'Exam Room',
                      value: myAllocation != null ? '${myAllocation['block']}' : 'TBA',
                      subtitle: 'Room ${myAllocation != null ? myAllocation['room'] : 'TBA'}',
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.groups_outlined,
                      title: 'Group',
                      value: userProfile.studentGroup ?? '—',
                      subtitle: '${myAllocation != null ? myAllocation['students'] : '?'} students',
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Exam Schedule (${examDays.length} exams)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 12),
              if (examDays.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No exam days configured yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                )
              else
                ...List.generate(examDays.length, (index) {
                  final day = examDays[index] as Map;
                  final date = DateTime.tryParse(day['date']?.toString() ?? '') ?? DateTime.now();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Text('DAY ${index + 1}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400)),
                            Text(DateFormat('dd').format(date), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(DateFormat('MMM').format(date).toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(day['subject']?.toString() ?? 'Subject TBA', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('${day['startTime'] ?? 'TBA'} – ${day['endTime'] ?? 'TBA'}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              Text('${myAllocation != null ? myAllocation['block'] : 'TBA'} · Room ${myAllocation != null ? myAllocation['room'] : 'TBA'}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.title, required this.value, required this.subtitle, required this.color});
  final IconData icon;
  final String title, value, subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
