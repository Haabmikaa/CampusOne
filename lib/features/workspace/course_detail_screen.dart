import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/data_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'workspace_creation_sheets.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId, this.course});
  final String courseId;
  final CourseModel? course;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget? _buildFab(BuildContext context) {
    switch (_tabController.index) {
      case 0: // Assignments
        return FloatingActionButton.extended(
          heroTag: 'detail_post_assignment',
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CreateAssignmentSheet(courseId: widget.courseId),
          ),
          icon: const Icon(Icons.assignment),
          label: const Text('Post Assignment'),
          backgroundColor: AppColors.primary600,
          foregroundColor: Colors.white,
        );
      case 1: // Resources
        return FloatingActionButton.extended(
          heroTag: 'detail_post_material',
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CreateMaterialSheet(courseId: widget.courseId),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Post Material'),
          backgroundColor: AppColors.primary600,
          foregroundColor: Colors.white,
        );
      case 2: // Discussions
        return FloatingActionButton.extended(
          heroTag: 'detail_post_announcement',
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => CreateAnnouncementSheet(cohort: widget.course?.cohort ?? ''),
          ),
          icon: const Icon(Icons.message_rounded),
          label: const Text('Message Section'),
          backgroundColor: AppColors.primary600,
          foregroundColor: Colors.white,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    
    // Authorization Check
    final isStaff = userProfile?.role == UserRole.staff;
    final instructorId = widget.course?.instructorId ?? '';
    final isInstructor = userProfile?.uid == instructorId;

    if (isStaff && !isInstructor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Unauthorized')),
        body: const Center(
          child: EmptyState(
            icon: Icons.security_rounded,
            title: 'Access Denied',
            subtitle: 'You are not the assigned lecturer for this course.',
          ),
        ),
      );
    }

    final courseName = widget.course?.title ?? 'Course Details';
    final courseCode = widget.course?.courseCode ?? '';

    return Scaffold(
      floatingActionButton: isInstructor 
        ? _buildFab(context)
        : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary600,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                courseCode.isNotEmpty ? courseCode : courseName,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Icon(
                          isInstructor ? Icons.workspace_premium : Icons.school, 
                          size: 200, 
                          color: Colors.white.withOpacity(0.1)
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 40,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isInstructor)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text('LECTURER MODE', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                  ],
                                ),
                              ),
                            Text(
                              courseName,
                              style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Assignments'),
                  Tab(text: 'Resources'),
                  Tab(text: 'Discussions'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            isInstructor ? _TeacherAssignmentsTab(courseId: widget.courseId) : _AssignmentsTab(courseId: widget.courseId),
            isInstructor ? _TeacherResourcesTab(courseId: widget.courseId) : _ResourcesTab(courseId: widget.courseId),
            _DiscussionsTab(cohort: widget.course?.cohort ?? ''),
          ],
        ),
      ),
    );
  }
}

Future<void> _handleLaunchUrl(BuildContext context, String urlString) async {
  final url = Uri.parse(urlString);
  try {
    // Attempting direct launch without canLaunchUrl which can be unreliable on Android 11+
    final success = await launchUrl(
      url, 
      mode: LaunchMode.externalApplication,
    );
    
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening link: $e')),
      );
    }
  }
}

class _TeacherAssignmentsTab extends ConsumerWidget {
  const _TeacherAssignmentsTab({required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider(courseId));

    return assignmentsAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const CardSkeleton(),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (assignments) {
        if (assignments.isEmpty) {
          return const EmptyState(
            icon: Icons.assignment_turned_in,
            title: 'No Active Assignments',
            subtitle: 'You haven\'t posted any assignments for this course yet.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: assignments.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          assignment.title,
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Due ${assignment.dueDate.day}/${assignment.dueDate.month}',
                          style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(assignment.description, style: AppTypography.bodyMedium),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppPrimaryButton(
                          label: 'View Submissions',
                          onPressed: () {
                            context.push('/workspace/$courseId/submissions/${assignment.id}?title=${Uri.encodeComponent(assignment.title)}');
                          },
                          icon: Icons.inbox,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TeacherResourcesTab extends ConsumerWidget {
  const _TeacherResourcesTab({required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider(courseId));

    return materialsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (materials) {
        if (materials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_shared, size: 80, color: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
                const SizedBox(height: AppSpacing.md),
                Text('Course Materials', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text('Share lecture slides, PDFs, and links with your students.', style: AppTypography.bodyMedium, textAlign: TextAlign.center),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: materials.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final mat = materials[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: AppColors.primary100, child: Icon(Icons.link, color: AppColors.primary600)),
                title: Text(mat.title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(mat.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new), 
                  onPressed: () => _handleLaunchUrl(context, mat.linkUrl),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ResourcesTab extends ConsumerWidget {
  const _ResourcesTab({required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider(courseId));

    return materialsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (materials) {
        if (materials.isEmpty) {
          return const EmptyState(
            icon: Icons.folder_shared,
            title: 'No Materials',
            subtitle: 'No resources have been shared for this course yet.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: materials.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final mat = materials[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: AppColors.primary100, child: Icon(Icons.link, color: AppColors.primary600)),
                title: Text(mat.title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(mat.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new), 
                  onPressed: () => _handleLaunchUrl(context, mat.linkUrl),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DiscussionsTab extends ConsumerWidget {
  const _DiscussionsTab({required this.cohort});
  final String cohort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (cohort.isEmpty) {
      return const Center(child: Text('No cohort assigned to this course.'));
    }

    final announcementsAsync = ref.watch(courseAnnouncementsProvider(cohort));

    return announcementsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (announcements) {
        if (announcements.isEmpty) {
          return const EmptyState(
            icon: Icons.forum,
            title: 'Student Engagement',
            subtitle: 'No announcements or discussions yet. Tap "Message Section" to send a broadcast.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: announcements.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: AppColors.primary100, child: Icon(Icons.campaign, color: AppColors.primary600)),
                title: Text(announcement.title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(announcement.body),
              ),
            );
          },
        );
      },
    );
  }
}

class _AssignmentsTab extends ConsumerWidget {
  const _AssignmentsTab({required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider(courseId));

    return assignmentsAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, __) => const CardSkeleton(),
      ),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (assignments) {
        if (assignments.isEmpty) {
          return const EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No Assignments',
            subtitle: 'There are no pending assignments for this course.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: assignments.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final assignment = assignments[index];
            return _StudentAssignmentCard(assignment: assignment);
          },
        );
      },
    );
  }

  void _showSubmitSheet(BuildContext context, AssignmentModel assignment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SubmitAssignmentSheet(assignment: assignment),
    );
  }
}

class _StudentAssignmentCard extends ConsumerWidget {
  const _StudentAssignmentCard({required this.assignment});
  final AssignmentModel assignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionsProvider(assignment.id));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  assignment.title,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Due ${assignment.dueDate.day}/${assignment.dueDate.month}',
                  style: AppTypography.labelSmall.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(assignment.description, style: AppTypography.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          submissionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading submission status: $e'),
            data: (submissions) {
              if (submissions.isEmpty) {
                return AppPrimaryButton(
                  label: 'Submit Assignment',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => _SubmitAssignmentSheet(assignment: assignment),
                    );
                  },
                );
              }

              final submission = submissions.first;
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Text('Submitted', style: AppTypography.titleSmall.copyWith(color: AppColors.success)),
                      ],
                    ),
                    if (submission.grade != null && submission.grade!.isNotEmpty) ...[
                      const Divider(height: 24),
                      Text('Grade: ${submission.grade}', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      if (submission.feedback != null && submission.feedback!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('Feedback: ${submission.feedback}', style: AppTypography.bodyMedium),
                        ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubmitAssignmentSheet extends ConsumerStatefulWidget {
  const _SubmitAssignmentSheet({required this.assignment});
  final AssignmentModel assignment;

  @override
  ConsumerState<_SubmitAssignmentSheet> createState() => _SubmitAssignmentSheetState();
}

class _SubmitAssignmentSheetState extends ConsumerState<_SubmitAssignmentSheet> {
  final _commentCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final link = _linkCtrl.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a submission link.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        await ref.read(dataServiceProvider).submitAssignment({
          'assignmentId': widget.assignment.id,
          'studentId': user.uid,
          'fileUrl': link,
          'feedback': _commentCtrl.text.trim(),
          'submittedAt': FieldValue.serverTimestamp(),
        });
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment submitted successfully!'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit: $e'), backgroundColor: AppColors.error),
          );
       }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final sheetColor = Theme.of(context).bottomSheetTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submit Assignment',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _linkCtrl,
                  label: 'Submission Link (Google Drive, Docs, etc.)',
                  hint: 'https://docs.google.com/document/d/...',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextArea(
                  controller: _commentCtrl,
                  label: 'Add a private comment (Optional)',
                  hint: 'Anything you want the instructor to know...',
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 500,
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: 'Turn In',
                  onPressed: _submit,
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
