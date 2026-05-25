/// CampusOne — User model
class UserModel {
  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.studentId,
    this.cohort,
    this.yearSemester,
    this.section,
    this.studentGroup,
    this.photoUrl,
    this.fcmToken,
    this.isActive = true,
    this.createdAt,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? department;
  final String? studentId;
  final String? cohort;
  final String? yearSemester; // e.g. "3rd Year (1st Sem)"
  final String? section;      // e.g. "Section 1"
  final String? studentGroup; // e.g. "Group B"
  final String? photoUrl;
  final String? fcmToken;
  final bool isActive;
  final DateTime? createdAt;

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'student'),
      department: map['department'],
      studentId: map['studentId'],
      cohort: map['cohort'],
      yearSemester: map['yearSemester'],
      section: map['section'],
      studentGroup: map['studentGroup'],
      photoUrl: map['photoUrl'],
      fcmToken: map['fcmToken'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'role': role.value,
        'department': department,
        'studentId': studentId,
        'cohort': cohort,
        'yearSemester': yearSemester,
        'section': section,
        'studentGroup': studentGroup,
        'photoUrl': photoUrl,
        'fcmToken': fcmToken,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? department,
    String? studentId,
    String? cohort,
    String? yearSemester,
    String? section,
    String? studentGroup,
    String? photoUrl,
    String? fcmToken,
    bool? isActive,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        department: department ?? this.department,
        studentId: studentId ?? this.studentId,
        cohort: cohort ?? this.cohort,
        yearSemester: yearSemester ?? this.yearSemester,
        section: section ?? this.section,
        studentGroup: studentGroup ?? this.studentGroup,
        photoUrl: photoUrl ?? this.photoUrl,
        fcmToken: fcmToken ?? this.fcmToken,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
      );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  bool get isAdmin    => role == UserRole.admin;
  bool get isStaff    => role == UserRole.staff || role == UserRole.lecturer;
  bool get isStudent  => role == UserRole.student;
  bool get isLecturer => role == UserRole.lecturer;
}

enum UserRole {
  student('student'),
  staff('staff'),
  lecturer('lecturer'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String v) =>
      UserRole.values.firstWhere((r) => r.value == v, orElse: () => UserRole.student);

  String get displayName {
    switch (this) {
      case UserRole.student:  return 'Student';
      case UserRole.staff:    return 'Staff';
      case UserRole.lecturer: return 'Lecturer';
      case UserRole.admin:    return 'Administrator';
    }
  }
}
