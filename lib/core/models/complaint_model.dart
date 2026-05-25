import 'package:cloud_firestore/cloud_firestore.dart';

enum ComplaintStatus {
  pending('pending'),
  inReview('in_review'),
  resolved('resolved'),
  closed('closed');

  const ComplaintStatus(this.value);
  final String value;

  static ComplaintStatus fromString(String v) =>
      ComplaintStatus.values.firstWhere((r) => r.value == v, orElse: () => ComplaintStatus.pending);

  String get displayName {
    switch (this) {
      case ComplaintStatus.pending:  return 'Pending';
      case ComplaintStatus.inReview: return 'In Review';
      case ComplaintStatus.resolved: return 'Resolved';
      case ComplaintStatus.closed:   return 'Closed';
    }
  }
}

class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final ComplaintStatus status;
  final String studentId;
  final String? assignedTo;
  final String? department;
  final List<String> mediaUrls;
  final String priority;
  final double? rating;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.studentId,
    this.assignedTo,
    this.department,
    required this.mediaUrls,
    required this.priority,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> map, String id) {
    return ComplaintModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Other',
      status: ComplaintStatus.fromString(map['status'] ?? 'pending'),
      studentId: map['studentId'] ?? '',
      assignedTo: map['assignedTo'],
      department: map['department'],
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      priority: map['priority'] ?? 'Medium',
      rating: (map['rating'] as num?)?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'category': category,
        'status': status.value,
        'studentId': studentId,
        'assignedTo': assignedTo,
        'department': department,
        'mediaUrls': mediaUrls,
        'priority': priority,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
