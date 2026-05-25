import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/widgets/loading_skeleton.dart';
import '../../core/routing/app_router.dart';
import '../../core/models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showAllocationBottomSheet(BuildContext context, WidgetRef ref, UserModel? userProfile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AllocationBottomSheet(
        initialYearSemester: userProfile?.yearSemester,
        initialSection: userProfile?.section,
        initialGroup: userProfile?.studentGroup,
      ),
    );
  }

  List<_HubItem> _studentHubItems() => [
    const _HubItem(Icons.auto_stories_rounded, 'Workspace', Color(0xFFF97316), Color(0xFFFFF7ED), AppRoutes.workspace),
    const _HubItem(Icons.chat_bubble_rounded, 'Complaints', Color(0xFFEF4444), Color(0xFFFEF2F2), AppRoutes.complaints),
    const _HubItem(Icons.map_rounded, 'Campus Map', Color(0xFF10B981), Color(0xFFECFDF5), AppRoutes.map),
    const _HubItem(Icons.contact_page_rounded, 'Directory', Color(0xFFF59E0B), Color(0xFFFFFBEB), AppRoutes.directory),
    const _HubItem(Icons.menu_book_rounded, 'Library', Color(0xFF0EA5E9), Color(0xFFF0F9FF), AppRoutes.library),
    const _HubItem(Icons.grid_view_rounded, 'Services', Color(0xFF2563EB), Color(0xFFEFF6FF), AppRoutes.services),
    const _HubItem(Icons.event_rounded, 'Events', Color(0xFF8B5CF6), Color(0xFFF5F3FF), '${AppRoutes.announcements}?category=Events'),
  ];

  List<_HubItem> _staffHubItems() => [
    const _HubItem(Icons.map_rounded, 'Campus Map', Color(0xFF8B5CF6), Color(0xFFF5F3FF), AppRoutes.map),
    const _HubItem(Icons.contact_page_rounded, 'Directory', Color(0xFFF59E0B), Color(0xFFFFFBEB), AppRoutes.directory),
    const _HubItem(Icons.campaign_rounded, 'Notices', Color(0xFF3B82F6), Color(0xFFEFF6FF), AppRoutes.announcements),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    final cs = Theme.of(context).colorScheme;

    if (user == null) {
      return Scaffold(
        body: Column(
          children: [
            const LoadingSkeleton(width: double.infinity, height: 200, borderRadius: 0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  children: [
                    const CardSkeleton(),
                    const SizedBox(height: AppSpacing.xl),
                    const CardSkeleton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isStudent = userProfile?.role == UserRole.student;
    final hubItems = isStudent ? _studentHubItems() : _staffHubItems();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 252,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: const Color(0xFF1D4ED8),
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipPath(
                clipper: const WaveClipper(
                  bottomInset: 0,
                  firstEndInset: -22,
                  secondControlInset: 8,
                ),
                child: Container(
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.neutral0.withValues(alpha: 0.25), width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 38,
                            backgroundColor: AppColors.neutral0,
                            child: Icon(Icons.person_rounded, size: 42, color: AppColors.primary600),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          userProfile?.name ?? user.displayName ?? 'User', 
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.neutral0, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neutral0.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            userProfile?.email ?? user.email ?? '', 
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.neutral0.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildSectionHeader('Account Information', cs),
                  AppCard(
                    child: Column(
                      children: [
                        _InfoRow(Icons.badge_outlined, 'ID', userProfile?.studentId ?? 'STU-2024-001'),
                        _buildCustomDivider(cs),
                        _InfoRow(Icons.school_outlined, 'Department', userProfile?.department ?? 'Computer Science'),
                        _buildCustomDivider(cs),
                        _InfoRow(Icons.email_outlined, 'Email', userProfile?.email ?? user.email ?? ''),
                      ],
                    ),
                  ),

                  // Class Allocation Section for Students
                  if (isStudent) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader('Class Allocation', cs),
                    AppCard(
                      child: Column(
                        children: [
                          _AllocationTile(
                            icon: Icons.grid_view_rounded,
                            label: 'Year & Semester',
                            value: userProfile?.yearSemester ?? 'Not Selected',
                            onTap: () => _showAllocationBottomSheet(context, ref, userProfile),
                          ),
                          _buildCustomDivider(cs),
                          _AllocationTile(
                            icon: Icons.view_module_rounded,
                            label: 'Section',
                            value: userProfile?.section ?? 'Not Selected',
                            onTap: () => _showAllocationBottomSheet(context, ref, userProfile),
                          ),
                          _buildCustomDivider(cs),
                          _AllocationTile(
                            icon: Icons.groups_rounded,
                            label: 'Group',
                            value: userProfile?.studentGroup ?? 'Not Selected',
                            onTap: () => _showAllocationBottomSheet(context, ref, userProfile),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Campus Hub Section
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionHeader('Campus Hub', cs),
                  AppCard(
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: hubItems.length,
                      itemBuilder: (context, i) {
                        final item = hubItems[i];
                        return _HubTile(
                          icon: item.icon,
                          label: item.label,
                          color: item.color,
                          bg: item.bg,
                          onTap: () => context.push(item.route),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionHeader('Preferences', cs),
                  AppCard(
                    child: SwitchListTile(
                      value: ref.watch(themeModeProvider) == ThemeMode.dark ||
                             (ref.watch(themeModeProvider) == ThemeMode.system &&
                              MediaQuery.platformBrightnessOf(context) == Brightness.dark),
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).toggleTheme(val);
                      },
                      title: Text('Dark Mode', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.dark_mode_outlined, color: cs.onSurface, size: 20),
                      ),
                      contentPadding: EdgeInsets.zero,
                      activeColor: cs.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    child: _MenuTile(Icons.logout_rounded, 'Sign Out', AppColors.error, () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                              ),
                              const SizedBox(width: 12),
                              const Text('Sign Out'),
                            ],
                          ),
                          content: const Text(
                            'Are you sure you want to sign out of your account?',
                            style: TextStyle(fontSize: 15),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancel', style: TextStyle(color: cs.onSurfaceVariant)),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) context.go(AppRoutes.login);
                      }
                    }),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.md),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: cs.onSurface.withValues(alpha: 0.85),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCustomDivider(ColorScheme cs) {
    return Divider(
      height: 24,
      thickness: 0.8,
      color: cs.onSurface.withValues(alpha: 0.06),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: cs.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label, 
            style: AppTypography.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppSpacing.md), 
          Expanded(
            child: Text(
              value,
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile(this.icon, this.label, this.color, this.onTap);
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        label, 
        style: AppTypography.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, size: 20, color: color.withValues(alpha: 0.6)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _AllocationTile extends StatelessWidget {
  const _AllocationTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });
  
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isNotSelected = value == 'Not Selected';
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: cs.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: AppTypography.titleSmall.copyWith(
                      color: isNotSelected ? Colors.amber.shade800 : cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllocationBottomSheet extends ConsumerStatefulWidget {
  const _AllocationBottomSheet({
    required this.initialYearSemester,
    required this.initialSection,
    required this.initialGroup,
  });

  final String? initialYearSemester;
  final String? initialSection;
  final String? initialGroup;

  @override
  ConsumerState<_AllocationBottomSheet> createState() => _AllocationBottomSheetState();
}

class _AllocationBottomSheetState extends ConsumerState<_AllocationBottomSheet> {
  String? _selectedYearSemester;
  String? _selectedSection;
  String? _selectedGroup;
  bool _isLoading = false;

  final List<String> _yearSemesters = [
    '1st Year (1st Semester)',
    '1st Year (2nd Semester)',
    '2nd Year (1st Semester)',
    '2nd Year (2nd Semester)',
    '3rd Year (1st Semester)',
    '3rd Year (2nd Semester)',
    '4th Year (1st Semester)',
    '4th Year (2nd Semester)',
    '5th Year (1st Semester)',
    '5th Year (2nd Semester)',
  ];

  final List<String> _sections = [
    'Section 1',
    'Section 2',
    'Section 3',
    'Section 4',
    'Section 5',
    'Section 6',
  ];
  final List<String> _groups = [
    'Group 1',
    'Group 2',
    'Group 3',
    'Group 4',
    'Group 5',
    'Group 6',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYearSemester =
        _yearSemesters.contains(widget.initialYearSemester) ? widget.initialYearSemester : null;
    _selectedSection = _sections.contains(widget.initialSection) ? widget.initialSection : null;
    _selectedGroup = _groups.contains(widget.initialGroup) ? widget.initialGroup : null;
  }

  Future<void> _save() async {
    if (_selectedYearSemester == null || _selectedSection == null || _selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Year/Semester, Section, and Group.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user != null) {
        final profile = ref.read(currentUserProvider).valueOrNull;
        final department = profile?.department;
        if (department == null || department.trim().isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please set your department first.')),
            );
          }
          return;
        }

        final yearLevel = _selectedYearSemester!.split(' ').take(2).join(' ');
        final cohort = '$yearLevel $department';
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'cohort': cohort,
          'yearSemester': _selectedYearSemester,
          'section': _selectedSection,
          'studentGroup': _selectedGroup,
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Class allocation updated!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        24 + mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom +
            (mediaQuery.viewInsets.bottom == 0 ? 80 : 0),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.school_rounded, color: cs.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Text(
                  'Class Allocation',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.3),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Select your section and group to get access to class schedule and courses.',
              style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant, height: 1.3),
            ),
            const SizedBox(height: 28),
            
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Year & Semester',
                prefixIcon: const Icon(Icons.calendar_today_rounded, size: 20),
                labelStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
              ),
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              value: _yearSemesters.contains(_selectedYearSemester) ? _selectedYearSemester : null,
              items: _yearSemesters
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedYearSemester = val),
            ),
            const SizedBox(height: 18),

            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Select Section',
                prefixIcon: const Icon(Icons.view_module_rounded, size: 20),
                labelStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
              ),
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              value: _sections.contains(_selectedSection) ? _selectedSection : null,
              items: _sections
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedSection = val),
            ),
            const SizedBox(height: 18),
            
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Select Group',
                prefixIcon: const Icon(Icons.groups_rounded, size: 20),
                labelStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.8)),
              ),
              dropdownColor: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              value: _groups.contains(_selectedGroup) ? _selectedGroup : null,
              items: _groups
                  .map((g) => DropdownMenuItem(
                        value: g,
                        child: Text(
                          g,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedGroup = val),
            ),
            
            const SizedBox(height: 36),
            AppPrimaryButton(
              onPressed: _isLoading ? null : _save,
              label: 'Save Allocation',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _HubItem {
  const _HubItem(this.icon, this.label, this.color, this.bg, this.route);
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final String route;
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.12), width: 1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: cs.onSurface.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
