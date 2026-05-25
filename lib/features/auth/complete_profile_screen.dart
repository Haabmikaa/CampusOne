import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/widgets.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  String? _selectedDepartment;
  String? _selectedYearLevel;
  String? _selectedSection;
  String? _selectedGroup;
  bool _isLoading = false;

  // Departments must match what admin uses in the schedule panel
  static const _departments = [
    'Civil Engineering',
    'Architecture',
    'Water Resources Engineering',
    'Pre Engineering',
    'Software Engineering',
    'Computer Science Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Material Engineering',
    'Chemical Engineering',
    'Physics',
    'Mathematics',
    'ECE',
    'EPE',
  ];

  static const _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    '5th Year',
  ];

  static const _semesters = [
    '1st Semester',
    '2nd Semester',
  ];

  static const _sections = [
    'Section 1',
    'Section 2',
    'Section 3',
    'Section 4',
    'Section 5',
    'Section 6',
  ];

  String? _selectedSemester;

  final List<String> _groups = [
    'Group 1',
    'Group 2',
    'Group 3',
    'Group 4',
    'Group 5',
    'Group 6',
  ];

  Future<void> _saveProfile() async {
    if (_selectedDepartment == null || _selectedYearLevel == null ||
        _selectedSemester == null || _selectedSection == null || _selectedGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // cohort = "2nd Year Civil Engineering" — must match admin Excel section headers
    final cohort = '$_selectedYearLevel $_selectedDepartment';
    final yearSemester = '$_selectedYearLevel ($_selectedSemester)';

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'cohort': cohort,
          'yearSemester': yearSemester,
          'section': _selectedSection,
          'studentGroup': _selectedGroup,
          'department': _selectedDepartment,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary500),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primary500, width: 2),
        ),
      ),
      dropdownColor: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral500),
      value: value,
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(
          item.toString(),
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      )).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.school_rounded, size: 80, color: AppColors.primary600),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Complete Your Profile',
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Select your department and year to receive your specific class and exam schedules.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.neutral500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Department
                _buildDropdown<String>(
                  label: 'Department / Program',
                  icon: Icons.business_rounded,
                  value: _selectedDepartment,
                  items: _departments,
                  onChanged: (val) => setState(() => _selectedDepartment = val),
                ),
                const SizedBox(height: AppSpacing.md),

                // Year Level
                _buildDropdown<String>(
                  label: 'Year Level',
                  icon: Icons.school_rounded,
                  value: _selectedYearLevel,
                  items: _yearLevels,
                  onChanged: (val) => setState(() => _selectedYearLevel = val),
                ),
                const SizedBox(height: AppSpacing.md),

                // Semester
                _buildDropdown<String>(
                  label: 'Current Semester',
                  icon: Icons.calendar_today_rounded,
                  value: _selectedSemester,
                  items: _semesters,
                  onChanged: (val) => setState(() => _selectedSemester = val),
                ),
                const SizedBox(height: AppSpacing.md),

                // Section
                _buildDropdown<String>(
                  label: 'Select Section',
                  icon: Icons.view_module_rounded,
                  value: _selectedSection,
                  items: _sections,
                  onChanged: (val) => setState(() => _selectedSection = val),
                ),
                const SizedBox(height: AppSpacing.md),

                // Group
                _buildDropdown<String>(
                  label: 'Student Group',
                  icon: Icons.groups_rounded,
                  value: _selectedGroup,
                  items: _groups,
                  onChanged: (val) => setState(() => _selectedGroup = val),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Preview cohort
                if (_selectedDepartment != null && _selectedYearLevel != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary600.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary600.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary600, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your section: $_selectedYearLevel $_selectedDepartment',
                            style: const TextStyle(
                              color: AppColors.primary600,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.xl),
                AppPrimaryButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  label: 'Save & Continue',
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    ref.read(profileSetupSkippedProvider.notifier).state = true;
                  },
                  child: const Text(
                    'Add Later',
                    style: TextStyle(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
