import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import '../../core/routing/app_router.dart';
import '../../core/widgets/widgets.dart';

class LecturerHomeScreen extends ConsumerWidget {
  const LecturerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final coursesAsync = ref.watch(coursesProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final greeting = _greeting();
    final firstName = user.name.trim().split(' ').first;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Top Bar ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: _LecturerTopBar(user: user, isDark: isDark),
            ),

            // ── Hero Welcome Card ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: _WelcomeCard(
                  greeting: greeting,
                  name: firstName,
                  cohort: user.cohort ?? 'Not assigned',
                  department: user.department ?? 'Department',
                  isDark: isDark,
                ),
              ),
            ),

            // ── Quick Stats ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: coursesAsync.when(
                  loading: () => const StatsSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (courses) => _StatsRow(courseCount: courses.length),
                ),
              ),
            ),

            // ── Quick Actions ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: _SectionHeader(title: 'Quick Actions'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _QuickActions(context: context),
              ),
            ),

            // ── My Courses ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                child: _SectionHeader(
                  title: 'My Courses',
                  actionLabel: 'Workspace',
                  onAction: () => context.push(AppRoutes.workspace),
                ),
              ),
            ),
            coursesAsync.when(
              loading: () => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: SizedBox(height: 100, child: CardSkeleton()),
                  ),
                  childCount: 3,
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: ErrorState(message: e.toString()),
              ),
              data: (courses) {
                if (courses.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.auto_stories_outlined, size: 40, color: cs.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text('No courses assigned yet', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Contact admin to get courses linked to your account.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: _CourseCard(course: courses[i]),
                    ),
                    childCount: courses.length,
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────
class _LecturerTopBar extends StatelessWidget {
  const _LecturerTopBar({required this.user, required this.isDark});
  final UserModel user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          Text(
            'CampusOne',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Lecturer badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF4F46E5).withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_pin_circle_rounded, size: 14, color: Color(0xFF4F46E5)),
                SizedBox(width: 4),
                Text('Lecturer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: cs.primaryContainer,
            child: Text(user.initials, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Welcome Card ─────────────────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.greeting,
    required this.name,
    required this.cohort,
    required this.department,
    required this.isDark,
  });
  final String greeting, name, cohort, department;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E3A5F), const Color(0xFF0D2137)]
              : [const Color(0xFF1565C0), const Color(0xFF0D47A1)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Dr. $name', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.groups_rounded, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(cohort, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(department, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cast_for_education_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.courseCount});
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _StatTile(label: 'Courses', value: '$courseCount', icon: Icons.book_rounded, color: const Color(0xFF4F46E5), cs: cs),
        const SizedBox(width: 12),
        _StatTile(label: 'Assigned Section', value: '1', icon: Icons.groups_rounded, color: const Color(0xFF059669), cs: cs),
        const SizedBox(width: 12),
        _StatTile(label: 'Pending', value: '—', icon: Icons.pending_actions_rounded, color: const Color(0xFFD97706), cs: cs),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, required this.icon, required this.color, required this.cs});
  final String label, value;
  final IconData icon;
  final Color color;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    final cs = Theme.of(context).colorScheme;
    final actions = [
      _Action('My Workspace', Icons.folder_open_rounded, const Color(0xFF4F46E5), const Color(0xFFEDE9FE), () => context.push(AppRoutes.workspace)),
      _Action('Class Schedule', Icons.calendar_today_rounded, const Color(0xFF059669), const Color(0xFFD1FAE5), () => context.push(AppRoutes.schedule)),
      _Action('Notices', Icons.campaign_rounded, const Color(0xFFD97706), const Color(0xFFFEF3C7), () => context.push(AppRoutes.announcements)),
      _Action('Campus Map', Icons.map_rounded, const Color(0xFF0284C7), const Color(0xFFE0F2FE), () => context.push(AppRoutes.map)),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 0,
      childAspectRatio: 0.85,
      children: actions.map((a) => _ActionTile(action: a, cs: cs)).toList(),
    );
  }
}

class _Action {
  final String label;
  final IconData icon;
  final Color color, bgColor;
  final VoidCallback onTap;
  const _Action(this.label, this.icon, this.color, this.bgColor, this.onTap);
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action, required this.cs});
  final _Action action;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: action.bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(action.icon, color: action.color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            action.label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
      ],
    );
  }
}

// ── Course Card ───────────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final CourseModel course;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.push('/workspace/${course.id}', extra: course),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(course.courseCode, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.groups_outlined, size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(course.cohort, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
