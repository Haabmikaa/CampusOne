import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import '../../core/models/user_model.dart';
import '../../core/routing/app_router.dart';
import '../../core/widgets/widgets.dart';
import 'hidden_actions_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final now = DateTime.now();
    final greeting = _greeting(now.hour);

    return userAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const Scaffold(body: Center(child: Text('Error loading profile'))),
      data: (user) {
        if (user?.role == UserRole.staff) {
          return _StaffHomeScreen(user: user!, greeting: greeting, now: now);
        }
        return _StudentHomeScreen(user: user, greeting: greeting, now: now);
      },
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }
}

// ─────────────────────────────────────────────
// STUDENT HOME SCREEN
// ─────────────────────────────────────────────
class _StudentHomeScreen extends ConsumerWidget {
  const _StudentHomeScreen({required this.user, required this.greeting, required this.now});
  final UserModel? user;
  final String greeting;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiddenActionsAsync = ref.watch(hiddenActionsProvider);
    final hiddenActions = hiddenActionsAsync.valueOrNull ?? [];
    final allActions = _studentActions();
    final visibleActions = allActions.where((a) => !hiddenActions.contains(a.label)).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentUserProvider);
            ref.invalidate(announcementsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: const SliverToBoxAdapter(child: _TopBar()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _HeroCard(
                      greeting: greeting,
                      name: user?.name.split(' ').first ?? 'Student',
                      role: user?.role.displayName ?? 'Student',
                      date: DateFormat('EEEE, MMM d').format(now),
                      gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      icon: Icons.waving_hand_rounded,
                    ),
                    const SizedBox(height: 20),
                    const _NextUpCard(),
                    const SizedBox(height: 24),
                    _SectionHeader(title: 'Quick Actions', actionLabel: 'Customize', onAction: () => _showCustomizeSheet(context, allActions)),
                    const SizedBox(height: 16),
                    if (visibleActions.isEmpty)
                      Center(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text('All actions hidden. Tap Customize to restore.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                      ))
                    else
                      _QuickActionsGrid(actions: visibleActions),
                    const SizedBox(height: 16),
                    _SectionHeader(title: 'Latest Announcements', actionLabel: 'See All', onAction: () => context.push(AppRoutes.announcements)),
                    const SizedBox(height: 12),
                    const _AnnouncementsPreview(),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_ActionItem> _studentActions() => [
    _ActionItem(Icons.chat_bubble_rounded, 'Complaint', const Color(0xFFEF4444), const Color(0xFFFEF2F2), AppRoutes.complaints),
    _ActionItem(Icons.map_rounded, 'Map', const Color(0xFF10B981), const Color(0xFFECFDF5), AppRoutes.map),
    _ActionItem(Icons.campaign_rounded, 'Notices', const Color(0xFF3B82F6), const Color(0xFFEFF6FF), AppRoutes.announcements),
    _ActionItem(Icons.contact_page_rounded, 'Directory', const Color(0xFFF59E0B), const Color(0xFFFFFBEB), AppRoutes.directory),
    _ActionItem(Icons.event_rounded, 'Events', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), '${AppRoutes.announcements}?category=Events'),
    _ActionItem(Icons.menu_book_rounded, 'Library', const Color(0xFF0EA5E9), const Color(0xFFF0F9FF), AppRoutes.library),
    _ActionItem(Icons.school_rounded, 'Workspace', const Color(0xFFF97316), const Color(0xFFFFF7ED), AppRoutes.workspace),
    _ActionItem(Icons.grid_view_rounded, 'Services', const Color(0xFF2563EB), const Color(0xFFEFF6FF), AppRoutes.services),
  ];
}

// ─────────────────────────────────────────────
// STAFF HOME SCREEN
// ─────────────────────────────────────────────
class _StaffHomeScreen extends ConsumerWidget {
  const _StaffHomeScreen({required this.user, required this.greeting, required this.now});
  final UserModel user;
  final String greeting;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(complaintsProvider);
    final pendingCount = complaintsAsync.valueOrNull?.where((c) => c.status.value == 'pending' || c.status.value == 'in_review').length ?? 0;
    final resolvedCount = complaintsAsync.valueOrNull?.where((c) => c.status.value == 'resolved').length ?? 0;

    final hiddenActionsAsync = ref.watch(hiddenActionsProvider);
    final hiddenActions = hiddenActionsAsync.valueOrNull ?? [];
    final allActions = _staffActions();
    final visibleActions = allActions.where((a) => !hiddenActions.contains(a.label)).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(currentUserProvider);
            ref.invalidate(complaintsProvider);
            ref.invalidate(announcementsProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: const SliverToBoxAdapter(child: _TopBar()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Staff Hero Card (different colour — green/teal)
                    _HeroCard(
                      greeting: greeting,
                      name: user.name.split(' ').first,
                      role: '${user.role.displayName} · ${user.department ?? 'Campus Staff'}',
                      date: DateFormat('EEEE, MMM d').format(now),
                      gradientColors: const [Color(0xFF047857), Color(0xFF065F46)],
                      icon: Icons.engineering_rounded,
                    ),
                    const SizedBox(height: 20),
                    const _NextUpCard(),
                    const SizedBox(height: 24),

                    // Task Stats Row
                    Row(
                      children: [
                        Expanded(child: _StaffStatCard(
                          icon: Icons.pending_actions_rounded,
                          label: 'Active Tasks',
                          value: '$pendingCount',
                          color: const Color(0xFFF59E0B),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StaffStatCard(
                          icon: Icons.check_circle_rounded,
                          label: 'Resolved',
                          value: '$resolvedCount',
                          color: const Color(0xFF10B981),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StaffStatCard(
                          icon: Icons.assignment_rounded,
                          label: 'Total',
                          value: '${(complaintsAsync.valueOrNull ?? []).length}',
                          color: const Color(0xFF3B82F6),
                        )),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions — staff focused
                    _SectionHeader(title: 'Staff Actions', actionLabel: 'Customize', onAction: () => _showCustomizeSheet(context, allActions)),
                    const SizedBox(height: 16),
                    if (visibleActions.isEmpty)
                      Center(child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text('All actions hidden. Tap Customize to restore.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                      ))
                    else
                      _QuickActionsGrid(actions: visibleActions),
                    const SizedBox(height: 16),

                    // Staff Announcements (filtered)
                    _SectionHeader(title: 'Staff Announcements', actionLabel: 'See All', onAction: () => context.push(AppRoutes.announcements)),
                    const SizedBox(height: 12),
                    const _AnnouncementsPreview(),
                    const SizedBox(height: 20),

                    // Recent Assigned Tasks preview
                    _SectionHeader(title: 'Recent Assigned Tasks', actionLabel: 'View All', onAction: () => context.push(AppRoutes.complaints)),
                    const SizedBox(height: 12),
                    complaintsAsync.when(
                      loading: () => const CardSkeleton(),
                      error: (e, _) => const SizedBox.shrink(),
                      data: (tasks) {
                        if (tasks.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
                            child: Center(child: Text('No tasks assigned yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13))),
                          );
                        }
                        return Column(
                          children: tasks.take(3).map((t) => _TaskPreviewCard(title: t.title, status: t.status.value, category: t.category)).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_ActionItem> _staffActions() => [
    _ActionItem(Icons.task_alt_rounded, 'My Tasks', const Color(0xFF10B981), const Color(0xFFECFDF5), AppRoutes.complaints),
    _ActionItem(Icons.campaign_rounded, 'Notices', const Color(0xFF3B82F6), const Color(0xFFEFF6FF), AppRoutes.announcements),
    _ActionItem(Icons.map_rounded, 'Campus Map', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), AppRoutes.map),
    _ActionItem(Icons.contact_page_rounded, 'Directory', const Color(0xFFF59E0B), const Color(0xFFFFFBEB), AppRoutes.directory),
    _ActionItem(Icons.event_rounded, 'Events', const Color(0xFFF97316), const Color(0xFFFFF7ED), '${AppRoutes.announcements}?category=Events'),
    _ActionItem(Icons.person_rounded, 'My Profile', const Color(0xFF2563EB), const Color(0xFFEFF6FF), AppRoutes.profile),
  ];
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = notificationsAsync.maybeWhen(
      data: (items) => items.where((item) => !item.isRead).length,
      orElse: () => 0,
    );

    return SafeArea(
      bottom: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Text('CampusOne', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface)),
        ]),
        Row(
          children: [
            GestureDetector(
              onTap: () => context.push(AppRoutes.notifications),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.notifications_none_rounded, size: 22, color: Color(0xFF1E293B)),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        constraints: const BoxConstraints(minWidth: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => context.go(AppRoutes.profile),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                child: Text(
                  user?.initials ?? '?',
                  style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.greeting, required this.name, required this.role, required this.date, required this.gradientColors, required this.icon});
  final String greeting, name, role, date;
  final List<Color> gradientColors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.38),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative background icon
                Positioned(
                  right: -14,
                  top: -14,
                  child: Icon(icon, color: Colors.white.withValues(alpha: 0.1), size: 140),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(greeting, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, letterSpacing: 0.3)),
                      const SizedBox(height: 4),
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.15)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified_user_outlined, color: Colors.white, size: 13),
                                const SizedBox(width: 5),
                                Text(role, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(date, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel, required this.onAction});
  final String title, actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        if (actionLabel.isNotEmpty)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3B82F6))),
          ),
      ],
    );
  }
}

class _NextUpCard extends ConsumerWidget {
  const _NextUpCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleProvider);
    final now = DateTime.now();
    // 1=Mon, ..., 7=Sun in DateTime, but dayIndex might be 0=Mon or 1=Mon.
    // Let's assume dayIndex 0=Monday, 1=Tuesday... 6=Sunday based on standard campus apps.
    final currentDayIndex = now.weekday - 1; 

    return scheduleAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        // Find next class today
        ScheduleItem? nextClass;
        final todayClasses = items.where((i) => i.dayIndex == currentDayIndex).toList();
        
        final currentTimeStr = DateFormat('HH:mm').format(now);
        
        for (final c in todayClasses) {
          if (c.startTime.compareTo(currentTimeStr) > 0) {
            nextClass = c;
            break;
          }
        }

        // If no more classes today, find first class tomorrow (or next available day)
        if (nextClass == null) {
          for (int i = 1; i <= 7; i++) {
            final nextDay = (currentDayIndex + i) % 7;
            final nextDayClasses = items.where((item) => item.dayIndex == nextDay).toList();
            if (nextDayClasses.isNotEmpty) {
              nextClass = nextDayClasses.first;
              break;
            }
          }
        }

        if (nextClass == null) return const SizedBox.shrink();

        final isToday = nextClass.dayIndex == currentDayIndex;
        final dayName = isToday ? 'Today' : _getDayName(nextClass.dayIndex);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push(AppRoutes.schedule),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NEXT UP: ${nextClass.subject}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1D4ED8)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$dayName at ${nextClass.startTime} • Room ${nextClass.room}',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF3B82F6)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDayName(int index) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return index >= 0 && index < 7 ? days[index] : '';
  }
}

class _StaffStatCard extends StatelessWidget {
  const _StaffStatCard({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TaskPreviewCard extends StatelessWidget {
  const _TaskPreviewCard({required this.title, required this.status, required this.category});
  final String title, status, category;

  Color get _statusColor {
    switch (status) {
      case 'resolved': return const Color(0xFF10B981);
      case 'in_review': return const Color(0xFFF59E0B);
      default: return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Theme.of(context).colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(category, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _statusColor)),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.actions});
  final List<_ActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.88,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => _ActionTile(actions[index]),
    );
  }
}

class _ActionItem {
  final IconData icon; final String label, route; final Color color, bgColor;
  _ActionItem(this.icon, this.label, this.color, this.bgColor, this.route);
}

class _ActionTile extends StatelessWidget {
  const _ActionTile(this.action);
  final _ActionItem action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () { if (action.route != '#') context.push(action.route); },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Center(child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(action.icon, color: cs.primary, size: 20),
            )),
          ),
          const SizedBox(height: 5),
          Text(
            action.label,
            style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsPreview extends ConsumerWidget {
  const _AnnouncementsPreview();

  static const _catColors = {
    'Academic': Color(0xFF3B82F6),
    'Events': Color(0xFF8B5CF6),
    'Staff': Color(0xFF10B981),
    'Sports': Color(0xFFF59E0B),
    'IT': Color(0xFF0EA5E9),
    'Library': Color(0xFFF97316),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsAsync = ref.watch(visibleAnnouncementsProvider);

    return announcementsAsync.when(
      loading: () => const CardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'No announcements yet. Check back soon.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
            ),
          );
        }

        final displayItems = items.take(6).toList();

        return SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: displayItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final ann = displayItems[index];
              final catColor = _catColors[ann.category] ?? const Color(0xFF3B82F6);
              
              return GestureDetector(
                onTap: () => context.push('/announcements/${ann.id}'),
                child: Container(
                  width: 290,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ann.hasImage)
                          AnnouncementThumbnail(imageUrl: ann.imageUrl!)
                        else
                          Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [catColor.withOpacity(0.8), catColor.withOpacity(0.5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                _categoryIcon(ann.category),
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: catColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ann.category,
                                        style: TextStyle(
                                          color: catColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (ann.isUrgent)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'Urgent',
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ann.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ann.body,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Academic': return Icons.school_rounded;
      case 'Events': return Icons.event_rounded;
      case 'Staff': return Icons.engineering_rounded;
      case 'Sports': return Icons.sports_rounded;
      case 'IT': return Icons.computer_rounded;
      case 'Library': return Icons.menu_book_rounded;
      default: return Icons.campaign_rounded;
    }
  }
}

void _showCustomizeSheet(BuildContext context, List<_ActionItem> allActions) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CustomizeSheet(allActions: allActions),
  );
}

class _CustomizeSheet extends ConsumerWidget {
  const _CustomizeSheet({required this.allActions});
  final List<_ActionItem> allActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiddenActionsAsync = ref.watch(hiddenActionsProvider);
    final hiddenActions = hiddenActionsAsync.valueOrNull ?? [];
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customize Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text('Select the actions you want to see on your dashboard.', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: allActions.length,
              itemBuilder: (context, index) {
                final action = allActions[index];
                final isHidden = hiddenActions.contains(action.label);
                return CheckboxListTile(
                  value: !isHidden,
                  onChanged: (_) => ref.read(hiddenActionsProvider.notifier).toggle(action.label),
                  title: Text(action.label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: action.bgColor, borderRadius: BorderRadius.circular(8)),
                    child: Icon(action.icon, color: action.color, size: 20),
                  ),
                  activeColor: Theme.of(context).colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.trailing,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              onPressed: () => Navigator.pop(context),
              label: 'Done',
            ),
          ),
        ],
      ),
    );
  }
}
