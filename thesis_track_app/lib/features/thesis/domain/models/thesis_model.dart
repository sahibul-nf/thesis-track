import 'package:thesis_track_app/features/auth/domain/models/user_model.dart';

class ThesisModel {
  final String id;
  final String studentId;
  final String title;
  final String abstract;
  final String researchField;
  final String status;
  final DateTime submissionDate;
  final String? draftDocumentUrl;
  final String? finalDocumentUrl;
  final UserModel student;
  final List<UserModel> supervisors;
  final List<UserModel> examiners;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ThesisModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.abstract,
    required this.researchField,
    required this.status,
    required this.submissionDate,
    this.draftDocumentUrl,
    this.finalDocumentUrl,
    required this.student,
    required this.supervisors,
    required this.examiners,
    this.completedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ThesisModel.fromJson(Map<String, dynamic> json) {
    return ThesisModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      title: json['title'] as String,
      abstract: json['abstract'] as String,
      researchField: json['research_field'] as String,
      status: json['status'] as String,
      submissionDate: DateTime.parse(json['submission_date'] as String),
      draftDocumentUrl: json['draft_document_url'] as String?,
      finalDocumentUrl: json['final_document_url'] as String?,
      student: UserModel.fromJson(json['student'] as Map<String, dynamic>),
      supervisors: (json['supervisors'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      examiners: (json['examiners'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'title': title,
      'abstract': abstract,
      'research_field': researchField,
      'status': status,
      'submission_date': submissionDate.toIso8601String(),
      'draft_document_url': draftDocumentUrl,
      'final_document_url': finalDocumentUrl,
      'student': student.toJson(),
      'supervisors': supervisors.map((e) => e.toJson()).toList(),
      'examiners': examiners.map((e) => e.toJson()).toList(),
      'completed_date': completedDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ThesisModel copyWith({
    String? id,
    String? studentId,
    String? title,
    String? abstract,
    String? researchField,
    String? status,
    DateTime? submissionDate,
    String? draftDocumentUrl,
    String? finalDocumentUrl,
    UserModel? student,
    List<UserModel>? supervisors,
    List<UserModel>? examiners,
    DateTime? completedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ThesisModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      title: title ?? this.title,
      abstract: abstract ?? this.abstract,
      researchField: researchField ?? this.researchField,
      status: status ?? this.status,
      submissionDate: submissionDate ?? this.submissionDate,
      draftDocumentUrl: draftDocumentUrl ?? this.draftDocumentUrl,
      finalDocumentUrl: finalDocumentUrl ?? this.finalDocumentUrl,
      student: student ?? this.student,
      supervisors: supervisors ?? this.supervisors,
      examiners: examiners ?? this.examiners,
      completedDate: completedDate?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}