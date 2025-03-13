import 'package:flutter/material.dart';

enum UserRole {
  student('Student', Color(0xFF2196F3)), // Bright blue for students - learning/growth
  lecturer('Lecture', Color(0xFF009688)), // Teal for lecturers - wisdom/teaching
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
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == role.toLowerCase()
    );
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? nim;
  final String? nidn;
  final String? department;
  final String? year;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nim,
    this.nidn,
    required this.department,
    this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json, {String? role}) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(role) ?? UserRole.student,
      nim: json['nim'] as String?,
      nidn: json['nidn'] as String?,
      department: json['department'] as String?,
      year: json['year'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'nim': nim,
      'nidn': nidn,
      'department': department,
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
    String? nim,
    String? nidn,
    String? department,
    String? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      nim: nim ?? this.nim,
      nidn: nidn ?? this.nidn,
      department: department ?? this.department,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
