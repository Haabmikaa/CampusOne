import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import '../../core/models/user_model.dart';
import 'workspace_creation_sheets.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final coursesAsync = ref.watch(coursesProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    final isLecturer = user?.role == UserRole.lecturer || user?.role == UserRole.staff;
    final headerGradient = AppColors.primaryGradient;
    final headerColor = AppColors.primary600;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: _isSearching ? kToolbarHeight : 140,
            floating: false,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: headerColor,
            flexibleSpace: _isSearching 
                ? Container(decoration: BoxDecoration(gradient: headerGradient))
                : FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(gradient: headerGradient),
                    ),
                    title: const Text('Academic Workspace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
            title: _isSearching
                ? Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      autofocus: true,
                      style: const TextStyle(color: AppColors.neutral900, fontWeight: FontWeight.w500),
                      cursorColor: AppColors.primary600,
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        hintStyle: TextStyle(color: AppColors.neutral500.withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.search, color: AppColors.neutral500, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    ),
                  )
                : null,
            actions: [
              IconButton(
                icon: Icon(_isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _searchQuery = '';
                      _isSearching = false;
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
            ],
          ),
          coursesAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: LoadingSkeleton(width: double.infinity, height: 120),
                ),
                childCount: 4,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: ErrorState(message: e.toString()),
            ),
            data: (courses) {
              if (user != null && user.role == UserRole.student && (user.cohort == null || user.cohort!.trim().isEmpty)) {
                return SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.auto_stories_rounded,
                    title: 'Courses Allocation Not Selected',
                    subtitle: 'Select your section and group in your profile to load assigned courses.',
                    actionLabel: 'Set Section & Group',
                    onAction: () => context.go('/profile'),
                  ),
                );
              }

              final filtered = courses.where((c) {
                if (_searchQuery.isEmpty) return true;
                return c.title.toLowerCase().contains(_searchQuery) ||
                       c.courseCode.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.auto_stories_rounded,
                    title: _searchQuery.isEmpty ? 'No Courses Yet' : 'No matches found',
                    subtitle: _searchQuery.isEmpty 
                        ? 'You are not assigned to any courses for this term.'
                        : 'Try searching for a different code or title.',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: AppCard(
                          onTap: () => context.push('/workspace/${course.id}', extra: course),
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 8,
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: cs.primaryContainer,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            course.courseCode,
                                            style: AppTypography.labelSmall.copyWith(
                                              color: cs.onPrimaryContainer,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(course.title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 16, color: cs.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Instructor ID: ${course.instructorId.length > 5 ? course.instructorId.substring(0, 5) : course.instructorId}...',
                                            style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Icon(Icons.group_outlined, size: 16, color: cs.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(
                                          course.cohort,
                                          style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPostMaterialSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateMaterialSheet(courseId: 'all'), // Placeholder if needed globally
    );
  }

  void _showPostAssignmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateAssignmentSheet(courseId: 'all'),
    );
  }

  void _showPostAnnouncementSheet(BuildContext context) {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CreateAnnouncementSheet(cohort: user.cohort ?? ''),
      );
    }
  }
}
