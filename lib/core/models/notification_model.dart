import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  complaint('complaint'),
  announcement('announcement'),
  broadcast('broadcast'),
  assignment('assignment'),
  reminder('reminder'),
  system('system');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String v) =>
      NotificationType.values.firstWhere((r) => r.value == v, orElse: () => NotificationType.system);
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? referenceId; // Link to complaint ID or announcement ID
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.referenceId,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.fromString(map['type'] ?? 'system'),
      isRead: map['isRead'] ?? false,
      referenceId: map['referenceId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'type': type.value,
        'isRead': isRead,
        'referenceId': referenceId,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
