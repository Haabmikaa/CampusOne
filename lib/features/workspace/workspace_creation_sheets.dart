import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/data_provider.dart';
import '../../core/providers/auth_provider.dart';

class CreateAssignmentSheet extends ConsumerStatefulWidget {
  const CreateAssignmentSheet({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CreateAssignmentSheet> createState() => _CreateAssignmentSheetState();
}

class _CreateAssignmentSheetState extends ConsumerState<CreateAssignmentSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  DateTime? _dueDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title and due date.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(dataServiceProvider).createAssignment({
        'courseId': widget.courseId,
        'title': title,
        'description': _descCtrl.text.trim(),
        'dueDate': _dueDate,
        'attachmentUrl': _linkCtrl.text.trim(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment posted!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e'), backgroundColor: AppColors.error),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Post Assignment', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _titleCtrl, label: 'Assignment Title', hint: 'e.g. Midterm Project'),
            const SizedBox(height: 12),
            AppTextArea(controller: _descCtrl, label: 'Description', hint: 'Detailed instructions...'),
            const SizedBox(height: 12),
            AppTextField(controller: _linkCtrl, label: 'Resource Link (Optional)', hint: 'Google Drive link'),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Due Date'),
              subtitle: Text(_dueDate == null ? 'Not set' : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null && mounted) setState(() => _dueDate = date);
              },
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(label: 'Post', onPressed: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}

class CreateMaterialSheet extends ConsumerStatefulWidget {
  const CreateMaterialSheet({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CreateMaterialSheet> createState() => _CreateMaterialSheetState();
}

class _CreateMaterialSheetState extends ConsumerState<CreateMaterialSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final link = _linkCtrl.text.trim();
    if (title.isEmpty || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title and a link.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(dataServiceProvider).createMaterial({
        'courseId': widget.courseId,
        'title': title,
        'description': _descCtrl.text.trim(),
        'linkUrl': link,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material posted!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e'), backgroundColor: AppColors.error),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Post Material', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _titleCtrl, label: 'Material Title', hint: 'e.g. Chapter 1 Slides'),
            const SizedBox(height: 12),
            AppTextArea(controller: _descCtrl, label: 'Description (Optional)', hint: 'Read before next class...'),
            const SizedBox(height: 12),
            AppTextField(controller: _linkCtrl, label: 'Resource Link (Required)', hint: 'Google Drive link, YouTube...'),
            const SizedBox(height: 24),
            AppPrimaryButton(label: 'Post', onPressed: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}

class CreateAnnouncementSheet extends ConsumerStatefulWidget {
  const CreateAnnouncementSheet({super.key, required this.cohort});
  final String cohort;

  @override
  ConsumerState<CreateAnnouncementSheet> createState() => _CreateAnnouncementSheetState();
}

class _CreateAnnouncementSheetState extends ConsumerState<CreateAnnouncementSheet> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user != null) {
        await ref.read(dataServiceProvider).createAnnouncement({
          'title': title,
          'body': _bodyCtrl.text.trim(),
          'category': 'Class Update',
          'audience': 'student',
          'targetCohort': widget.cohort,
          'authorId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement sent!'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: AppColors.error),
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Message Section', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _titleCtrl, label: 'Subject', hint: 'e.g. Class Rescheduled'),
            const SizedBox(height: 12),
            AppTextArea(controller: _bodyCtrl, label: 'Message', hint: 'Type your message...'),
            const SizedBox(height: 24),
            AppPrimaryButton(label: 'Send', onPressed: _submit, isLoading: _isLoading),
          ],
        ),
      ),
    );
  }
}
