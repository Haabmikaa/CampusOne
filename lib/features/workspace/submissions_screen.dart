import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/data_provider.dart';

class SubmissionsScreen extends ConsumerWidget {
  const SubmissionsScreen({super.key, required this.assignmentId, required this.assignmentTitle});
  final String assignmentId;
  final String assignmentTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(submissionsProvider(assignmentId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Submissions'),
            Text(
              assignmentTitle,
              style: AppTypography.labelSmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox,
              title: 'No Submissions Yet',
              subtitle: 'Students have not submitted anything for this assignment.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: submissions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final sub = submissions[index];
              final isGraded = sub.grade != null && sub.grade!.isNotEmpty;

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Student ID: ${sub.studentId}', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isGraded ? AppColors.successSurface : AppColors.warningSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isGraded ? 'Graded' : 'Needs Grade',
                            style: AppTypography.labelSmall.copyWith(color: isGraded ? AppColors.success : AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Submitted on: ${sub.submittedAt.day}/${sub.submittedAt.month}/${sub.submittedAt.year}', style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link, color: AppColors.primary500),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sub.fileUrl,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.primary500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (sub.feedback != null && sub.feedback!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text('Student Note: ${sub.feedback}', style: AppTypography.bodySmall),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppPrimaryButton(
                      label: isGraded ? 'Update Grade' : 'Grade Submission',
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => _GradeSubmissionSheet(submission: sub),
                        );
                      },
                      icon: Icons.grading,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _GradeSubmissionSheet extends ConsumerStatefulWidget {
  const _GradeSubmissionSheet({required this.submission});
  final SubmissionModel submission;

  @override
  ConsumerState<_GradeSubmissionSheet> createState() => _GradeSubmissionSheetState();
}

class _GradeSubmissionSheetState extends ConsumerState<_GradeSubmissionSheet> {
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _feedbackCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _gradeCtrl = TextEditingController(text: widget.submission.grade ?? '');
    _feedbackCtrl = TextEditingController(text: widget.submission.feedback ?? '');
  }

  @override
  void dispose() {
    _gradeCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitGrade() async {
    final grade = _gradeCtrl.text.trim();
    if (grade.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(dataServiceProvider).gradeSubmission(
            widget.submission.id,
            grade,
            _feedbackCtrl.text.trim(),
          );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grade submitted!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Grade Submission', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _gradeCtrl,
            label: 'Grade (e.g. 95/100, A+)',
            hint: 'Enter grade',
          ),
          const SizedBox(height: 16),
          AppTextArea(
            controller: _feedbackCtrl,
            label: 'Lecturer Feedback',
            hint: 'Great work on this assignment...',
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: 'Save Grade',
            onPressed: _submitGrade,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}
