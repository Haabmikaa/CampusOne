import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Semantic status chip for complaints, announcements, etc.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.micro),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.fg),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: AppTypography.labelSmall.copyWith(
                color: config.fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  _ChipConfig _statusConfig(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return _ChipConfig(
          label: 'Pending',
          icon: Icons.schedule_rounded,
          bg: AppColors.warningSurface,
          fg: AppColors.warning,
        );
      case 'in_review':
      case 'in review':
        return _ChipConfig(
          label: 'In Review',
          icon: Icons.search_rounded,
          bg: AppColors.infoSurface,
          fg: AppColors.info,
        );
      case 'resolved':
        return _ChipConfig(
          label: 'Resolved',
          icon: Icons.check_circle_rounded,
          bg: AppColors.successSurface,
          fg: AppColors.success,
        );
      case 'closed':
        return _ChipConfig(
          label: 'Closed',
          icon: Icons.lock_rounded,
          bg: AppColors.neutral200,
          fg: AppColors.neutral600,
        );
      case 'urgent':
        return _ChipConfig(
          label: 'Urgent',
          icon: Icons.priority_high_rounded,
          bg: AppColors.errorSurface,
          fg: AppColors.error,
        );
      case 'new':
        return _ChipConfig(
          label: 'New',
          icon: Icons.fiber_new_rounded,
          bg: AppColors.primary100,
          fg: AppColors.primary600,
        );
      default:
        return _ChipConfig(
          label: s,
          icon: Icons.info_outline_rounded,
          bg: AppColors.neutral100,
          fg: AppColors.neutral600,
        );
    }
  }
}

class _ChipConfig {
  const _ChipConfig({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
}

/// Section header with optional action button
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: AppTypography.sectionHeader
                  .copyWith(color: cs.onSurface)),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!,
                style: AppTypography.labelLarge
                    .copyWith(color: cs.primary)),
          ),
      ],
    );
  }
}

/// Divider with label
class LabeledDivider extends StatelessWidget {
  const LabeledDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(label,
              style: AppTypography.labelSmall
                  .copyWith(color: cs.onSurfaceVariant)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
