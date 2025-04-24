import 'package:flutter/material.dart';

enum UserRole {
  student('Student',
      Color(0xFF2196F3)), // Bright blue for students - learning/growth
  lecturer(
      'Lecture', Color(0xFF009688)), // Teal for lecturers - wisdom/teaching
  admin(
      'Admin', Color(0xFF673AB7)), // Deep purple for admins - authority/control
  supervisor('Supervisor',
      Color(0xFF4CAF50)), // Green for supervisors - guidance/mentorship
  examiner('Examiner',
      Color(0xFF8BC34A)); // Light Green for examiners - evaluation/review

  final String name;
  final Color color;

  const UserRole(this.name, this.color);

  static UserRole? fromString(String? role) {
    if (role == null) return null;
    return UserRole.values
        .firstWhere((e) => e.name.toLowerCase() == role.toLowerCase());
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StudentData? studentData;
  final LecturerData? lecturerData;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.studentData,
    this.lecturerData,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? role}) {
    StudentData? studentData;
    LecturerData? lecturerData;
    if (role == 'Student') {
      studentData = StudentData(
        nim: json['nim'] as String,
        year: json['year'] as String,
      );
    } else if (role == 'Lecture') {
      lecturerData = LecturerData(
        nidn: json['nidn'] as String,
        totalThesisSupervised: json['total_thesis_supervised'] as int,
        totalThesisExamined: json['total_thesis_examined'] as int,
        onTrackThesisCount: json['on_track_thesis_count'] as int,
      );
    }

    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(role) ?? UserRole.student,
      studentData: studentData,
      lecturerData: lecturerData,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    String? nim;
    String? nidn;
    String? year;
    if (role == UserRole.student) {
      var studentData = this.studentData;
      nim = studentData?.nim;
      year = studentData?.year;
    } else if (role == UserRole.lecturer) {
      var lecturerData = this.lecturerData;
      nidn = lecturerData?.nidn;
    }

    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'nim': nim,
      'nidn': nidn,
      'year': year,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    StudentData? studentData,
    LecturerData? lecturerData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      studentData: studentData ?? this.studentData,
      lecturerData: lecturerData ?? this.lecturerData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class StudentData {
  final String nim;
  final String year;

  StudentData({required this.nim, required this.year});

  StudentData copyWith({
    String? nim,
    String? year,
  }) {
    return StudentData(
      nim: nim ?? this.nim,
      year: year ?? this.year,
    );
  }
}

class LecturerData {
  final String nidn;
  final int totalThesisSupervised;
  final int totalThesisExamined;
  final int onTrackThesisCount;

  LecturerData({
    required this.nidn,
    required this.totalThesisSupervised,
    required this.totalThesisExamined,
    required this.onTrackThesisCount,
  });

  LecturerData copyWith({
    String? nidn,
    int? totalThesisSupervised,
    int? totalThesisExamined,
    int? onTrackThesisCount,
  }) {
    return LecturerData(
      nidn: nidn ?? this.nidn,
      totalThesisSupervised:
          totalThesisSupervised ?? this.totalThesisSupervised,
      totalThesisExamined: totalThesisExamined ?? this.totalThesisExamined,
      onTrackThesisCount: onTrackThesisCount ?? this.onTrackThesisCount,
    );
  }
}
