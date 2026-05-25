import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_provider.dart';
import '../../core/models/announcement_model.dart';
import '../../core/models/user_model.dart';
import '../../core/widgets/widgets.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key, this.initialCategory});
  final String? initialCategory;

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen>
    with TickerProviderStateMixin {
  late String _selectedCategory;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _categories = ['All', 'Academic', 'Events', 'Staff', 'Sports', 'IT', 'Library'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(visibleAnnouncementsProvider);
    final userProfile = ref.watch(currentUserProvider).valueOrNull;
    final isStaff = userProfile?.role == UserRole.staff;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isStaff ? 'Campus Notices' : 'Announcements',
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _CategoryBar(
              categories: _categories,
              selected: _selectedCategory,
              onSelect: (c) => setState(() {
                _selectedCategory = c;
                _fadeCtrl.reset();
                _fadeCtrl.forward();
              }),
            ),
          ),
          announcementsAsync.when(
            loading: () => SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(padding: EdgeInsets.only(bottom: 16), child: CardSkeleton()),
                  childCount: 5,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text(e.toString(), style: const TextStyle(color: Colors.black54)))),
            data: (items) {
              final filtered = _selectedCategory == 'All'
                  ? items
                  : items.where((a) => a.category == _selectedCategory).toList();

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Icon(Icons.campaign_outlined, color: Theme.of(context).colorScheme.primary, size: 48),
                      ),
                      const SizedBox(height: 20),
                      Text('No Announcements', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Nothing posted in this category yet.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                    ]),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final ann = filtered[i];
                      final isFeatured = ann.isPinned;
                      return FadeTransition(
                        opacity: _fadeAnim,
                        child: isFeatured
                            ? _FeaturedCard(ann: ann)
                            : _AnnCard(ann: ann),
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
}

// ─── Category Bar ─────────────────────────────────────────
class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.categories, required this.selected, required this.onSelect});
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSel = selected == cat;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSel ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                ),
                boxShadow: isSel
                    ? [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isSel ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Featured/Pinned Card ─────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.ann});
  final AnnouncementModel ann;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/announcements/${ann.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.25), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ann.hasImage)
                Stack(
                  children: [
                    AnnouncementHeroImage(imageUrl: ann.imageUrl!, height: 160, borderRadius: BorderRadius.zero),
                    Container(height: 160, color: Colors.black.withOpacity(0.35)),
                  ],
                ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.push_pin_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Flexible(child: Text(ann.category.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1), overflow: TextOverflow.ellipsis)),
                          ]),
                        ),
                      ),
                      const Spacer(),
                      if (ann.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(8)),
                          child: const Text('URGENT', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                        ),
                    ]),
                    const SizedBox(height: 16),
                    Text(ann.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                    const SizedBox(height: 8),
                    Text(ann.body, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (ann.hasEventMeta) ...[
                      const SizedBox(height: 10),
                      Row(children: [
                        if (ann.eventDate != null && ann.eventDate!.isNotEmpty) ...[
                          Icon(Icons.event_rounded, size: 12, color: Colors.white.withOpacity(0.85)),
                          const SizedBox(width: 4),
                          Flexible(child: Text(ann.eventDate!, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11), overflow: TextOverflow.ellipsis)),
                        ],
                      ]),
                    ],
                    const SizedBox(height: 16),
                    Row(children: [
                      Icon(Icons.access_time_rounded, size: 12, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Text(_formatDate(ann.createdAt), style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                        child: const Row(children: [
                          Text('Read More', style: TextStyle(color: Color(0xFF2563EB), fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF2563EB)),
                        ]),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 1) return DateFormat('MMM d').format(d);
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }
}

// ─── Regular Announcement Card ────────────────────────────
class _AnnCard extends StatelessWidget {
  const _AnnCard({required this.ann});
  final AnnouncementModel ann;

  static const _catColors = {
    'Academic': Color(0xFF3B82F6),
    'Events': Color(0xFF8B5CF6),
    'Staff': Color(0xFF10B981),
    'Sports': Color(0xFFF59E0B),
    'IT': Color(0xFF0EA5E9),
    'Library': Color(0xFFF97316),
  };

  @override
  Widget build(BuildContext context) {
    final catColor = _catColors[ann.category] ?? const Color(0xFF3B82F6);

    return GestureDetector(
      onTap: () => context.push('/announcements/${ann.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (ann.hasImage)
                AnnouncementThumbnail(imageUrl: ann.imageUrl!)
              else
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [catColor.withOpacity(0.8), catColor.withOpacity(0.5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _categoryIcon(ann.category),
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(ann.category, style: TextStyle(color: catColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5), overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      const Spacer(),
                      Text(_formatDate(ann.createdAt), style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                    ]),
                    const SizedBox(height: 8),
                    Text(ann.title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold, height: 1.2), maxLines: 2),
                    const SizedBox(height: 6),
                    Text(ann.body, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (ann.hasEventMeta) ...[
                      const SizedBox(height: 12),
                      Row(children: [
                        if (ann.eventDate != null && ann.eventDate!.isNotEmpty) ...[
                          Icon(Icons.event_rounded, size: 14, color: Theme.of(context).colorScheme.tertiary),
                          const SizedBox(width: 6),
                          Text(ann.eventDate!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                        if (ann.location != null && ann.location!.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Flexible(child: Text(ann.location!, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12), overflow: TextOverflow.ellipsis)),
                        ],
                      ]),
                    ],
                    if (ann.isUrgent) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFCA5A5))),
                        child: const Text('⚡ URGENT', style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Academic': return Icons.school_rounded;
      case 'Events': return Icons.event_rounded;
      case 'Staff': return Icons.engineering_rounded;
      case 'Sports': return Icons.sports_rounded;
      case 'IT': return Icons.computer_rounded;
      case 'Library': return Icons.menu_book_rounded;
      default: return Icons.campaign_rounded;
    }
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays >= 1) return DateFormat('MMM d').format(d);
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
