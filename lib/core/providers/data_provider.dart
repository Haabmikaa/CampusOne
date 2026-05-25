import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../models/complaint_model.dart';
import '../models/announcement_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

// ─── Firestore Provider ───────────────────────────────────
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

String _normalizeDepartmentName(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return '';

  const aliases = {
    'ARCH': 'Architecture',
    'CE': 'Civil Engineering',
    'CHE': 'Chemical Engineering',
    'CHEMICAL ENGINEERING': 'Chemical Engineering',
    'COMPUTER SCIENCE ENGINEERING': 'Computer Science Engineering',
    'CS': 'Computer Science Engineering',
    'CSE': 'Computer Science Engineering',
    'ECE': 'ECE',
    'EEC': 'Electrical Engineering',
    'EE': 'Electrical Engineering',
    'ELECTRICAL ENGINEERING': 'Electrical Engineering',
    'EPE': 'EPE',
    'EPCE': 'Pre Engineering',
    'MATERIAL ENGINEERING': 'Material Engineering',
    'MATERIALS': 'Material Engineering',
    'MATHEMATICS': 'Mathematics',
    'MATH': 'Mathematics',
    'ME': 'Mechanical Engineering',
    'PHYSICS': 'Physics',
    'PRE': 'Pre Engineering',
    'PRE ENGINEERING': 'Pre Engineering',
    'SE': 'Software Engineering',
    'SOFTWARE ENGINEERING': 'Software Engineering',
    'WATER RESOURCES ENGINEERING': 'Water Resources Engineering',
    'WRE': 'Water Resources Engineering',
  };

  final aliasKey = trimmed.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]+'), ' ').trim();
  return aliases[aliasKey] ?? trimmed;
}

String? _extractYearLevel(UserModel userProfile) {
  final yearSemester = userProfile.yearSemester?.trim();
  if (yearSemester != null && yearSemester.isNotEmpty) {
    final match = RegExp(r'^\d+(st|nd|rd|th)\s+Year').firstMatch(yearSemester);
    if (match != null) return match.group(0);
  }

  final cohort = userProfile.cohort?.trim();
  if (cohort != null && cohort.isNotEmpty) {
    final match = RegExp(r'^\d+(st|nd|rd|th)\s+Year').firstMatch(cohort);
    if (match != null) return match.group(0);
  }

  return null;
}

// ─── Complaints Provider ──────────────────────────────────
final complaintsProvider = StreamProvider<List<ComplaintModel>>((ref) {
  final userProfile = ref.watch(currentUserProvider).valueOrNull;
  if (userProfile == null) return Stream.value([]);

  Query<Map<String, dynamic>> query = ref.watch(firestoreProvider).collection('complaints');

  if (userProfile.role == UserRole.student || userProfile.role == UserRole.lecturer) {
    query = query.where('studentId', isEqualTo: userProfile.uid);
  } else if (userProfile.role == UserRole.staff) {
    query = query.where('assignedTo', isEqualTo: userProfile.uid);
  }

  return query
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => ComplaintModel.fromMap(doc.data(), doc.id))
          .toList());
});

final complaintDetailProvider = StreamProvider.family<ComplaintModel?, String>((ref, id) {
  return ref
      .watch(firestoreProvider)
      .collection('complaints')
      .doc(id)
      .snapshots()
      .map((doc) => doc.exists ? ComplaintModel.fromMap(doc.data()!, doc.id) : null);
});

// ─── Announcements Provider ────────────────────────────────
final announcementsProvider = StreamProvider<List<AnnouncementModel>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('announcements')
      .orderBy('isPinned', descending: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => AnnouncementModel.fromMap(doc.data(), doc.id))
          .where((a) => !a.isExpired)
          .toList());
});

/// Announcements filtered by role audience (`all` / `student` / `staff`).
final visibleAnnouncementsProvider = Provider<AsyncValue<List<AnnouncementModel>>>((ref) {
  final raw = ref.watch(announcementsProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  return raw.whenData((items) {
    if (user == null) return <AnnouncementModel>[];
    return items.where((a) => a.isVisibleTo(user.role)).toList();
  });
});

final announcementDetailProvider =
    StreamProvider.family<AnnouncementModel?, String>((ref, id) {
  return ref
      .watch(firestoreProvider)
      .collection('announcements')
      .doc(id)
      .snapshots()
      .map((doc) =>
          doc.exists ? AnnouncementModel.fromMap(doc.data()!, doc.id) : null);
});

// ─── Notifications Provider ────────────────────────────────
final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value([]);

  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList());
});

// ─── Schedule Provider ───────────────────────────────────
final scheduleProvider = StreamProvider<List<ScheduleItem>>((ref) {
  final userProfile = ref.watch(currentUserProvider).valueOrNull;
  if (userProfile == null) return Stream.value([]);

  Query<Map<String, dynamic>> query = ref.watch(firestoreProvider).collection('schedules');

  if (userProfile.role == UserRole.student) {
    if (userProfile.cohort == null || userProfile.cohort!.trim().isEmpty) return Stream.value([]);
    query = query.where('cohort', isEqualTo: userProfile.cohort);
    if (userProfile.section != null && userProfile.section!.trim().isNotEmpty) {
      query = query.where('section', isEqualTo: userProfile.section);
    }
  } else if (userProfile.role == UserRole.staff || userProfile.role == UserRole.lecturer) {
    // Lecturers should see classes they are teaching
    query = query.where('instructorId', isEqualTo: userProfile.uid);
  }
  // Admin sees all schedules

  return query.snapshots().map((snap) {
    var list = snap.docs.map((doc) => ScheduleItem.fromMap(doc.data(), doc.id)).toList();

    if (userProfile.role == UserRole.student) {
      final group = userProfile.studentGroup;
      if (group != null && group.trim().isNotEmpty) {
        list = list.where((s) {
          if (s.group.trim().isEmpty) return true;
          if (s.group == 'Both') return true;
          return s.group == group;
        }).toList();
      }
    }
    // Sort by day then by time
    list.sort((a, b) {
      if (a.dayIndex != b.dayIndex) return a.dayIndex.compareTo(b.dayIndex);
      return a.startTime.compareTo(b.startTime);
    });
    return list;
  });
});
// ─── Complex Exam Schedule Provider ────────────────────────
// Queries by `cohort` field which is a composite key: "2nd Year Civil Engineering"
// This avoids a compound Firestore index (no orderBy needed).
final examScheduleProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final userProfile = ref.watch(currentUserProvider).valueOrNull;
  if (userProfile == null) return Stream.value(null);

  Query<Map<String, dynamic>> query = ref.watch(firestoreProvider).collection('exam_schedules');

  if (userProfile.role == UserRole.student) {
    final cohort = userProfile.cohort;
    if (cohort == null || cohort.trim().isEmpty) return Stream.value(null);
    query = query.where('cohort', isEqualTo: cohort);
  } else if (userProfile.role == UserRole.staff || userProfile.role == UserRole.lecturer) {
    final cohort = userProfile.cohort;
    if (cohort != null && cohort.trim().isNotEmpty) {
      query = query.where('cohort', isEqualTo: cohort);
    } else {
      return Stream.value(null);
    }
  }

  return query.limit(1).snapshots().map((snap) => snap.docs.isNotEmpty ? snap.docs.first.data() : null);
});

// ─── Staff Provider ──────────────────────────────────────
final staffProvider = StreamProvider<List<StaffModel>>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('staff')
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => StaffModel.fromMap(doc.data(), doc.id))
          .toList());
});

final assistantKnowledgeProvider = StreamProvider<String>((ref) {
  return ref
      .watch(firestoreProvider)
      .collection('app_config')
      .doc('assistant_kb')
      .snapshots()
      .map((doc) => doc.data()?['text']?.toString() ?? '');
});

// ─── Academic Workspace Providers ────────────────────────
final coursesProvider = StreamProvider<List<CourseModel>>((ref) {
  final userProfile = ref.watch(currentUserProvider).valueOrNull;
  if (userProfile == null) return Stream.value([]);

  Query<Map<String, dynamic>> query = ref.watch(firestoreProvider).collection('courses');
  
  if (userProfile.role == UserRole.student) {
    final studentDepartment = _normalizeDepartmentName(userProfile.department);
    final studentYear = _extractYearLevel(userProfile);
    if (studentDepartment.isEmpty || studentYear == null) return Stream.value([]);
    query = query.where('year', isEqualTo: studentYear);
  } else if (userProfile.role == UserRole.staff || userProfile.role == UserRole.lecturer) {
    query = query.where('instructorId', isEqualTo: userProfile.uid);
  }

  return query.snapshots().map((snap) {
    var docs = snap.docs;

    if (userProfile.role == UserRole.student) {
      final studentDepartment = _normalizeDepartmentName(userProfile.department);
      final studentSection = userProfile.section?.trim();

      docs = docs.where((doc) {
        final data = doc.data();
        final courseDepartment = _normalizeDepartmentName(data['department']?.toString());
        if (courseDepartment != studentDepartment) return false;

        if (studentSection != null && studentSection.isNotEmpty) {
          final courseSection = data['section']?.toString().trim() ?? '';
          if (courseSection != studentSection) return false;
        }

        return true;
      }).toList();
    }

    final list = docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList();

    // Secondary filtering for Students based on Group
    if (userProfile.role == UserRole.student) {
      return list.where((course) {
        // Show if course is for 'Both' groups OR matches student's specific group
        return course.group == 'Both' || course.group == userProfile.studentGroup;
      }).toList();
    }
    
    return list;
  });
});

final assignmentsProvider = StreamProvider.family<List<AssignmentModel>, String>((ref, courseId) {
  return ref
      .watch(firestoreProvider)
      .collection('assignments')
      .where('courseId', isEqualTo: courseId)
      .snapshots()
      .map((snap) {
        final list = snap.docs
            .map((doc) => AssignmentModel.fromMap(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        return list;
      });
});

final materialsProvider = StreamProvider.family<List<MaterialModel>, String>((ref, courseId) {
  return ref
      .watch(firestoreProvider)
      .collection('materials')
      .where('courseId', isEqualTo: courseId)
      .snapshots()
      .map((snap) {
        final list = snap.docs
            .map((doc) => MaterialModel.fromMap(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
});

final courseAnnouncementsProvider = StreamProvider.family<List<AnnouncementModel>, String>((ref, cohort) {
  return ref
      .watch(firestoreProvider)
      .collection('announcements')
      .where('targetCohort', isEqualTo: cohort)
      .snapshots()
      .map((snap) {
         final list = snap.docs
          .map((doc) => AnnouncementModel.fromMap(doc.data(), doc.id))
          .toList();
         list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
         return list;
      });
});

final submissionsProvider = StreamProvider.family<List<SubmissionModel>, String>((ref, assignmentId) {
  final userProfile = ref.watch(currentUserProvider).valueOrNull;
  if (userProfile == null) return Stream.value([]);

  Query<Map<String, dynamic>> query = ref.watch(firestoreProvider)
      .collection('submissions')
      .where('assignmentId', isEqualTo: assignmentId);

  if (userProfile.role == UserRole.student) {
    query = query.where('studentId', isEqualTo: userProfile.uid);
  }

  return query.snapshots().map((snap) => snap.docs
      .map((doc) => SubmissionModel.fromMap(doc.data(), doc.id))
      .toList());
});

// ─── Data Services ────────────────────────────────────────
final dataServiceProvider = Provider((ref) => DataService(ref));

class DataService {
  final Ref _ref;
  DataService(this._ref);

  FirebaseFirestore get _db => _ref.read(firestoreProvider);
  CollectionReference<Map<String, dynamic>> _userNotifications(String userId) =>
      _db.collection('users').doc(userId).collection('notifications');

  Future<void> _createUserNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? referenceId,
  }) async {
    await _userNotifications(userId).add(
      NotificationModel(
        id: '',
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }

  void _queueUserNotification(
    WriteBatch batch, {
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? referenceId,
  }) {
    final doc = _userNotifications(userId).doc();
    batch.set(
      doc,
      NotificationModel(
        id: doc.id,
        title: title,
        body: body,
        type: type,
        referenceId: referenceId,
        createdAt: DateTime.now(),
      ).toMap(),
    );
  }

  String _complaintStatusBody(String title, ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.pending:
        return 'Your complaint "$title" is pending review.';
      case ComplaintStatus.inReview:
        return 'Your complaint "$title" is now in review.';
      case ComplaintStatus.resolved:
        return 'Your complaint "$title" has been resolved.';
      case ComplaintStatus.closed:
        return 'Your complaint "$title" has been closed.';
    }
  }

  Future<void> submitComplaint(ComplaintModel complaint) async {
    await _db.collection('complaints').add(complaint.toMap());
  }

  Future<void> updateComplaintStatus(String complaintId, ComplaintStatus newStatus) async {
    final complaintRef = _db.collection('complaints').doc(complaintId);
    final complaintSnap = await complaintRef.get();
    final complaint = complaintSnap.exists
        ? ComplaintModel.fromMap(complaintSnap.data()!, complaintSnap.id)
        : null;

    await complaintRef.update({
      'status': newStatus.value,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (complaint != null && complaint.studentId.trim().isNotEmpty) {
      await _createUserNotification(
        userId: complaint.studentId,
        title: 'Complaint ${newStatus.displayName}',
        body: _complaintStatusBody(complaint.title, newStatus),
        type: NotificationType.complaint,
        referenceId: complaint.id,
      );
    }
  }

  Future<void> markNotificationAsRead(String userId, String notifId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notifId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final batch = _db.batch();
    final snaps = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in snaps.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> postClassStatusMessage(String scheduleId, String message, Duration duration) async {
    final expiresAt = DateTime.now().add(duration);
    await _db.collection('schedules').doc(scheduleId).update({
      'statusMessage': message,
      'statusExpiresAt': Timestamp.fromDate(expiresAt),
    });
  }

  Future<void> createAssignment(Map<String, dynamic> data) async {
    final assignmentRef = await _db.collection('assignments').add(data);
    final courseId = data['courseId']?.toString();
    if (courseId == null || courseId.trim().isEmpty) return;

    final courseSnap = await _db.collection('courses').doc(courseId).get();
    if (!courseSnap.exists) return;

    final course = CourseModel.fromMap(courseSnap.data()!, courseSnap.id);
    final assignmentTitle = data['title']?.toString().trim();
    if (assignmentTitle == null || assignmentTitle.isEmpty) return;

    Query<Map<String, dynamic>> query = _db
        .collection('users')
        .where('role', isEqualTo: UserRole.student.value)
        .where('cohort', isEqualTo: course.cohort);

    if (course.section.trim().isNotEmpty) {
      query = query.where('section', isEqualTo: course.section);
    }

    if (course.group.trim().isNotEmpty && course.group != 'Both') {
      query = query.where('studentGroup', isEqualTo: course.group);
    }

    final studentSnap = await query.get();
    if (studentSnap.docs.isEmpty) return;

    final batch = _db.batch();
    final courseLabel =
        course.courseCode.trim().isNotEmpty ? course.courseCode : course.title;

    for (final studentDoc in studentSnap.docs) {
      _queueUserNotification(
        batch,
        userId: studentDoc.id,
        title: 'New Assignment Posted',
        body: '$assignmentTitle is now available in $courseLabel.',
        type: NotificationType.assignment,
        referenceId: assignmentRef.id,
      );
    }

    await batch.commit();
  }

  Future<void> createMaterial(Map<String, dynamic> data) async {
    await _db.collection('materials').add(data);
  }

  Future<void> submitAssignment(Map<String, dynamic> data) async {
    await _db.collection('submissions').add(data);
  }

  Future<void> gradeSubmission(String submissionId, String grade, String feedback) async {
    await _db.collection('submissions').doc(submissionId).update({
      'grade': grade,
      'feedback': feedback,
    });
  }

  Future<void> createAnnouncement(Map<String, dynamic> data) async {
    final announcementRef = await _db.collection('announcements').add(data);
    final audience = data['audience']?.toString().trim() ?? 'all';
    final targetCohort = data['targetCohort']?.toString().trim();
    final title = data['title']?.toString().trim();
    final body = data['body']?.toString().trim();
    if (title == null || title.isEmpty || body == null || body.isEmpty) return;

    Query<Map<String, dynamic>> query = _db.collection('users');

    if (audience == 'staff') {
      query = _db
          .collection('users')
          .where('role', whereIn: [UserRole.staff.value, UserRole.lecturer.value]);
    } else if (audience == 'student') {
      query = _db.collection('users').where('role', isEqualTo: UserRole.student.value);
    }

    if (targetCohort != null && targetCohort.isNotEmpty) {
      query = query.where('cohort', isEqualTo: targetCohort);
    }

    final recipients = await query.get();
    if (recipients.docs.isEmpty) return;

    final batch = _db.batch();
    for (final recipient in recipients.docs) {
      _queueUserNotification(
        batch,
        userId: recipient.id,
        title: title,
        body: body,
        type: NotificationType.announcement,
        referenceId: announcementRef.id,
      );
    }
    await batch.commit();
  }
}

// ─── Data Models ──────────────────────────────────────────

enum ScheduleType { classType, exam }

class ScheduleItem {
  final String id, cohort;
  final ScheduleType type;

  // Class specific
  final String subject, instructor, instructorId, room, startTime, endTime;
  final int dayIndex;
  
  // Status fields
  final String? statusMessage;
  final DateTime? statusExpiresAt;

  // Exam specific
  final String courseCode, courseName, group, blockAndRoom;
  final String mainInvigilator, reserveInvigilator;
  final DateTime? examDate;
  final String examTimeSlot;

  ScheduleItem({
    required this.id, required this.cohort, this.type = ScheduleType.classType,
    this.subject = '', this.instructor = '', this.instructorId = '', this.room = '', this.startTime = '', this.endTime = '', this.dayIndex = 0,
    this.statusMessage, this.statusExpiresAt,
    this.courseCode = '', this.courseName = '', this.group = '', this.blockAndRoom = '',
    this.mainInvigilator = '', this.reserveInvigilator = '', this.examDate, this.examTimeSlot = '',
  });

  factory ScheduleItem.fromMap(Map<String, dynamic> map, String id) {
    return ScheduleItem(
      id: id,
      cohort: map['cohort'] ?? '',
      type: map['type'] == 'exam' ? ScheduleType.exam : ScheduleType.classType,
      subject: map['subject'] ?? '',
      instructor: map['instructor'] ?? '',
      instructorId: map['instructorId'] ?? '',
      room: map['room'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      dayIndex: map['dayIndex'] ?? 0,
      statusMessage: map['statusMessage'],
      statusExpiresAt: map['statusExpiresAt'] != null ? (map['statusExpiresAt'] as Timestamp).toDate() : null,
      courseCode: map['courseCode'] ?? '',
      courseName: map['courseName'] ?? '',
      group: map['group'] ?? '',
      blockAndRoom: map['blockAndRoom'] ?? '',
      mainInvigilator: map['mainInvigilator'] ?? '',
      reserveInvigilator: map['reserveInvigilator'] ?? '',
      examDate: map['examDate'] != null ? DateTime.tryParse(map['examDate'].toString()) : null,
      examTimeSlot: map['examTimeSlot'] ?? '',
    );
  }
}

// ─── Academic Workspace Models ────────────────────────────

class CourseModel {
  final String id, courseCode, title, instructorId, cohort, section, group;
  
  CourseModel({
    required this.id, 
    required this.courseCode, 
    required this.title, 
    required this.instructorId, 
    required this.cohort, 
    required this.section,
    required this.group,
  });
  
  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      courseCode: map['courseCode'] ?? '',
      title: map['title'] ?? '',
      instructorId: map['instructorId'] ?? '',
      cohort: map['cohort'] ?? '',
      section: map['section'] ?? '',
      group: map['group'] ?? 'Both',
    );
  }
}

class AssignmentModel {
  final String id, courseId, title, description;
  final DateTime dueDate;
  final String? attachmentUrl;

  AssignmentModel({required this.id, required this.courseId, required this.title, required this.description, required this.dueDate, this.attachmentUrl});

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AssignmentModel(
      id: id,
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] != null ? (map['dueDate'] as Timestamp).toDate() : DateTime.now(),
      attachmentUrl: map['attachmentUrl'],
    );
  }
}

class MaterialModel {
  final String id, courseId, title, description, linkUrl;
  final DateTime createdAt;

  MaterialModel({required this.id, required this.courseId, required this.title, required this.description, required this.linkUrl, required this.createdAt});

  factory MaterialModel.fromMap(Map<String, dynamic> map, String id) {
    return MaterialModel(
      id: id,
      courseId: map['courseId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      linkUrl: map['linkUrl'] ?? '',
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

class SubmissionModel {
  final String id, assignmentId, studentId, fileUrl;
  final DateTime submittedAt;
  final String? grade;
  final String? feedback;

  SubmissionModel({required this.id, required this.assignmentId, required this.studentId, required this.fileUrl, required this.submittedAt, this.grade, this.feedback});

  factory SubmissionModel.fromMap(Map<String, dynamic> map, String id) {
    return SubmissionModel(
      id: id,
      assignmentId: map['assignmentId'] ?? '',
      studentId: map['studentId'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      submittedAt: map['submittedAt'] != null ? (map['submittedAt'] as Timestamp).toDate() : DateTime.now(),
      grade: map['grade'],
      feedback: map['feedback'],
    );
  }
}

class StaffModel {
  final String id, name, department, role, email, phone, hours;

  StaffModel({
    required this.id, required this.name, required this.department, 
    required this.role, required this.email, required this.phone, required this.hours
  });

  factory StaffModel.fromMap(Map<String, dynamic> map, String id) {
    return StaffModel(
      id: id,
      name: map['name'] ?? '',
      department: map['department'] ?? '',
      role: map['role'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      hours: map['hours'] ?? '',
    );
  }

  String get initials {
    final parts = name.replaceAll(RegExp(r'(Dr\.|Mr\.|Ms\.|Inst\.)'), '').trim().split(' ');
    return parts.length >= 2 ? '${parts[0][0]}${parts[1][0]}'.toUpperCase() : name[0].toUpperCase();
  }
}
