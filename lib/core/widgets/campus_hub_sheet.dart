import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/constants.dart';
import '../routing/app_routes.dart';
import '../models/user_model.dart';

/// Quick-launch grid for modules moved off the bottom navigation bar.
class CampusHubSheet extends StatelessWidget {
  const CampusHubSheet({super.key, required this.role});

  final UserRole role;

  static Future<void> show(BuildContext context, {required UserRole role}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CampusHubSheet(role: role),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = role == UserRole.staff ? _staffItems() : _studentItems();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary600.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.apps_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Campus Hub', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800)),
                        Text(
                          'Workspace, services & more',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.neutral500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  return _HubTile(
                    icon: item.icon,
                    label: item.label,
                    color: item.color,
                    bg: item.bg,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(item.route);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_HubItem> _studentItems() => [
    _HubItem(Icons.auto_stories_rounded, 'Workspace', const Color(0xFFF97316), const Color(0xFFFFF7ED), AppRoutes.workspace),
    _HubItem(Icons.chat_bubble_rounded, 'Complaints', const Color(0xFFEF4444), const Color(0xFFFEF2F2), AppRoutes.complaints),
    _HubItem(Icons.map_rounded, 'Campus Map', const Color(0xFF10B981), const Color(0xFFECFDF5), AppRoutes.map),
    _HubItem(Icons.contact_page_rounded, 'Directory', const Color(0xFFF59E0B), const Color(0xFFFFFBEB), AppRoutes.directory),
    _HubItem(Icons.menu_book_rounded, 'Library', const Color(0xFF0EA5E9), const Color(0xFFF0F9FF), AppRoutes.library),
    _HubItem(Icons.grid_view_rounded, 'Services', const Color(0xFF2563EB), const Color(0xFFEFF6FF), AppRoutes.services),
    _HubItem(Icons.event_rounded, 'Events', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), '${AppRoutes.announcements}?category=Events'),
    _HubItem(Icons.person_rounded, 'Profile', const Color(0xFF3B82F6), const Color(0xFFEFF6FF), AppRoutes.profile),
  ];

  List<_HubItem> _staffItems() => [
    _HubItem(Icons.map_rounded, 'Campus Map', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), AppRoutes.map),
    _HubItem(Icons.contact_page_rounded, 'Directory', const Color(0xFFF59E0B), const Color(0xFFFFFBEB), AppRoutes.directory),
    _HubItem(Icons.campaign_rounded, 'Notices', const Color(0xFF3B82F6), const Color(0xFFEFF6FF), AppRoutes.announcements),
    _HubItem(Icons.person_rounded, 'Profile', const Color(0xFF10B981), const Color(0xFFECFDF5), AppRoutes.profile),
  ];
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.w600,
                fontSize: 10,
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
