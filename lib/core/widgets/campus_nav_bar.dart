import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/constants.dart';
import '../routing/app_routes.dart';
import '../models/user_model.dart';
import 'campus_hub_sheet.dart';

/// Glass dock with centered AI core — selection pill wraps each icon in-place.
class CampusNavBar extends StatelessWidget {
  const CampusNavBar({
    super.key,
    required this.selectedIndex,
    required this.isStaff,
    required this.userRole,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final bool isStaff;
  final UserRole userRole;
  final ValueChanged<int> onTabSelected;

  static const double _dockHeight = 64;
  static const double _aiSize = 58;
  static const double _aiLift = 22;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final destinations = isStaff
        ? (userRole == UserRole.lecturer ? _lecturerTabMeta : _staffTabMeta)
        : _studentTabMeta;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, _aiLift, 16, bottomPad + 10),
      child: SizedBox(
        height: _dockHeight + _aiLift,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Glass bar (clips only the bar, not the AI button)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _dockHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1A1A1A).withValues(alpha: 0.94)
                              : Colors.white.withValues(alpha: 0.94),
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF0A0A0A).withValues(alpha: 0.82)
                              : Colors.white.withValues(alpha: 0.82),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.7),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withValues(alpha: 0.4)
                              : AppColors.primary600.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _slot(
                          destinations[0],
                          selectedIndex == 0,
                          () => onTabSelected(0),
                        ),
                        _slot(
                          destinations[1],
                          selectedIndex == 1,
                          () => onTabSelected(1),
                        ),
                        const SizedBox(width: _aiSize + 8),
                        _slot(
                          destinations[2],
                          selectedIndex == 2,
                          () => onTabSelected(2),
                        ),
                        _slot(
                          destinations[3],
                          selectedIndex == 3,
                          () => onTabSelected(3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // AI — sits above the bar, fully visible (no parent clip)
            Positioned(
              bottom: _dockHeight - (_aiSize / 2) - 2,
              child: _AiCoreButton(
                size: _aiSize,
                onTap: () => context.push(AppRoutes.assistant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(
    _TabMeta meta,
    bool selected,
    VoidCallback onTap, {
    bool isHub = false,
  }) {
    return Expanded(
      child: _DockItem(
        icon: meta.icon,
        label: meta.label,
        isSelected: selected,
        onTap: onTap,
        isHub: isHub,
      ),
    );
  }

  static const _studentTabMeta = [
    _TabMeta(Icons.home_rounded, 'Home'),
    _TabMeta(Icons.calendar_month_rounded, 'Schedule'),
    _TabMeta(Icons.campaign_rounded, 'Notices'),
    _TabMeta(Icons.person_rounded, 'Profile'),
  ];

  static const _staffTabMeta = [
    _TabMeta(Icons.dashboard_rounded, 'Portal'),
    _TabMeta(Icons.campaign_rounded, 'Notices'),
    _TabMeta(Icons.task_alt_rounded, 'Tasks'),
    _TabMeta(Icons.person_rounded, 'Profile'),
  ];

  static const _lecturerTabMeta = [
    _TabMeta(Icons.home_rounded, 'Home'),
    _TabMeta(Icons.campaign_rounded, 'Notices'),
    _TabMeta(Icons.workspace_premium_rounded, 'Workspace'),
    _TabMeta(Icons.person_rounded, 'Profile'),
  ];
}

class _TabMeta {
  const _TabMeta(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _AiCoreButton extends StatefulWidget {
  const _AiCoreButton({required this.size, required this.onTap});
  final double size;
  final VoidCallback onTap;

  @override
  State<_AiCoreButton> createState() => _AiCoreButtonState();
}

class _AiCoreButtonState extends State<_AiCoreButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final glow = 0.3 + (_pulse.value * 0.2);
          return Container(
            width: s + 8,
            height: s + 8,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary600.withValues(alpha: glow),
                  blurRadius: 16 + (_pulse.value * 6),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          );
        },
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF2563EB), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: s * 0.42),
              Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: s * 0.14,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isHub = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isHub;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary600 : AppColors.neutral500;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: CampusNavBar._dockHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: isSelected ? 48 : 40,
                height: isSelected ? 34 : 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.primary600.withValues(alpha: 0.16),
                            AppColors.primary400.withValues(alpha: 0.06),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.primary600.withValues(alpha: 0.22))
                      : null,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: isSelected ? 22 : 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
