import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

/// Campus notice / event published from the admin panel.
class AnnouncementModel {
  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.department,
    this.imageUrl,
    this.location,
    this.eventDate,
    this.eventTime,
    this.audience = 'all',
    this.isPinned = false,
    this.isUrgent = false,
    required this.authorId,
    required this.createdAt,
    this.expiresAt,
    this.targetCohort,
  });

  final String id;
  final String title;
  final String body;
  final String category;
  final String? department;
  final String? imageUrl;
  final String? location;
  final String? eventDate;
  final String? eventTime;
  /// `all` | `student` | `staff` — matches admin panel audience targeting.
  final String audience;
  final bool isPinned;
  final bool isUrgent;
  final String authorId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? targetCohort;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  bool get hasEventMeta =>
      (eventDate != null && eventDate!.isNotEmpty) ||
      (location != null && location!.isNotEmpty);

  bool get isEventCategory => category == 'Events';

  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      category: map['category'] ?? 'General',
      department: map['department'],
      imageUrl: map['imageUrl'] as String?,
      location: map['location'] as String?,
      eventDate: map['eventDate'] as String?,
      eventTime: map['eventTime'] as String?,
      audience: map['audience'] as String? ?? 'all',
      isPinned: map['isPinned'] ?? false,
      isUrgent: map['isUrgent'] ?? false,
      authorId: map['authorId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      targetCohort: map['targetCohort'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'category': category,
        'department': department,
        'imageUrl': imageUrl,
        'location': location,
        'eventDate': eventDate,
        'eventTime': eventTime,
        'audience': audience,
        'isPinned': isPinned,
        'isUrgent': isUrgent,
        'authorId': authorId,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        'targetCohort': targetCohort,
      };

  /// Whether this post is visible to the given user role.
  bool isVisibleTo(UserRole role) {
    if (role == UserRole.admin) return true;
    if (audience == 'all' || audience.isEmpty) return true;
    if (role == UserRole.student) return audience == 'student';
    if (role == UserRole.staff) return audience == 'staff';
    return false;
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
