import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/widgets.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import '../../core/models/complaint_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewComplaintScreen extends ConsumerStatefulWidget {
  const NewComplaintScreen({super.key});
  @override
  ConsumerState<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends ConsumerState<NewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Facilities';
  String _priority = 'Medium';
  bool _isLoading = false;
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  static const _categories = ['Facilities', 'IT Support', 'Catering', 'Security', 'Academic', 'Administration', 'Other'];
  static const _priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _images.add(File(image.path)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    
    try {
      final List<String> mediaUrls = []; 
      
      // Mocking image upload for now (Firebase Storage requires Spark/Blaze plan setup)
      if (_images.isNotEmpty) {
        // In a real scenario, you'd upload to Firebase Storage
        // For now, we'll use a placeholder and show a "Coming Soon" message
        for (var i = 0; i < _images.length; i++) {
          mediaUrls.add('https://placeholder.com/image_$i.png');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note: Real image uploads are currently disabled (Mocked).'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      final complaint = ComplaintModel(
        id: '', // Firestore will generate the ID
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        status: ComplaintStatus.pending,
        studentId: user.uid,
        mediaUrls: mediaUrls,
        priority: _priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(dataServiceProvider).submitComplaint(complaint);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('New Complaint')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Complaint Title',
                  hint: 'Brief description of the issue',
                  controller: _titleCtrl,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.title_rounded),
                  validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Category
                Text('Category', style: AppTypography.titleSmall.copyWith(color: cs.onSurface)),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: _categories.map((c) => ChoiceChip(
                    label: Text(c, style: TextStyle(color: _category == c ? Colors.white : cs.onSurface)),
                    selectedColor: AppColors.primary600,
                    backgroundColor: cs.surfaceContainerHighest,
                    selected: _category == c,
                    onSelected: (_) => setState(() => _category = c),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),

                // Priority
                Text('Priority', style: AppTypography.titleSmall.copyWith(color: cs.onSurface)),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: _priorities.map((p) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        label: Text(p, textAlign: TextAlign.center, style: TextStyle(color: _priority == p ? Colors.white : cs.onSurface)),
                        selectedColor: AppColors.primary600,
                        backgroundColor: cs.surfaceContainerHighest,
                        selected: _priority == p,
                        onSelected: (_) => setState(() => _priority = p),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextArea(
                  label: 'Detailed Description',
                  hint: 'Describe the issue in detail...',
                  controller: _descCtrl,
                  maxLength: 1000,
                  validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Attach media
                Text('Attachments', style: AppTypography.titleSmall.copyWith(color: cs.onSurface)),
                const SizedBox(height: AppSpacing.xs),
                if (_images.isNotEmpty) ...[
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                      itemBuilder: (_, i) {
                        if (i == _images.length) {
                          return _AddImageBtn(onTap: _pickImage);
                        }
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              child: Image.file(_images[i], width: 80, height: 80, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 4, right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _images.removeAt(i)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ] else
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.attach_file_rounded),
                    label: const Text('Attach Photo / Video'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
                    ),
                  ),
                
                const SizedBox(height: AppSpacing.xl),

                AppPrimaryButton(
                  label: 'Submit Complaint',
                  onPressed: _submit,
                  isLoading: _isLoading,
                  icon: Icons.send_rounded,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddImageBtn extends StatelessWidget {
  const _AddImageBtn({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: const Icon(Icons.add_a_photo_rounded, size: 24),
      ),
    );
  }
}

