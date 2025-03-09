import 'package:flutter/material.dart' show Colors, Color;
import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

// enum ThesisStatus {
//   pending('Pending'),
//   inProgress('In Progress'),
//   underReview('Under Review'),
//   completed('Completed');

//   final String name;

//   const ThesisStatus(this.name);

//   static ThesisStatus fromString(String? value) {
//     if (value == null) return pending;
//     return ThesisStatus.values.firstWhere((e) => e.name == value);
//   }

//   /// Get color of status
//   static Color getColor(ThesisStatus status) {
//     return switch (status) {
//       pending => Colors.orange.shade300, // Warm warning color for pending
//       inProgress => Colors.blue.shade400, // Active color for in progress
//       underReview =>
//         Colors.purple.shade300, // Distinguished color for review phase
//       completed => Colors.green.shade400, // Success color for completion
//     };
//   }
// }

enum ThesisStatus {
  unknown,
  pending,
  inProgress,
  underReview,
  completed;

  /// Get color of status
  Color get color {
    return switch (this) {
      pending => Colors.orange.shade300,
      inProgress => Colors.blue.shade400,
      underReview => Colors.purple.shade300,
      completed => Colors.green.shade400,
      unknown => Colors.grey.shade300,
    };
  }

  /// Get name of status
  String get name {
    return switch (this) {
      pending => 'Pending',
      inProgress => 'In Progress',
      underReview => 'Under Review',
      completed => 'Completed',
      unknown => 'Unknown',
    };
  }

  /// From string
  static ThesisStatus fromString(String value) {
    return ThesisStatus.values.firstWhereOrNull((e) => e.name == value) ??
        unknown;
  }
}

class Thesis {
  final String id;
  final String studentId;
  final String supervisorId; // Main Supervisor
  final String title;
  final String abstract;
  final String researchField;
  final ThesisStatus status;
  final DateTime submissionDate;
  final DateTime? completionDate;
  final String? draftDocumentUrl;
  final String? finalDocumentUrl;
  final bool isProposalReady;
  final bool isFinalExamReady;
  final User student;
  final User mainSupervisor;
  final List<ThesisLecture> supervisors;
  final List<ThesisLecture> examiners;
  final DateTime createdAt;
  final DateTime updatedAt;

  Thesis({
    required this.id,
    required this.studentId,
    required this.supervisorId,
    required this.title,
    required this.abstract,
    required this.researchField,
    required this.status,
    required this.submissionDate,
    this.completionDate,
    this.draftDocumentUrl,
    this.finalDocumentUrl,
    required this.isProposalReady,
    required this.isFinalExamReady,
    required this.student,
    required this.mainSupervisor,
    required this.supervisors,
    required this.examiners,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Progresses
  var progresses = RxList<ProgressModel>([]);

  /// List of members (supervisors, examiners, student)
  List<User> get members {
    return [
      ...supervisors.map((e) => e.user),
      ...examiners.map((e) => e.user),
      student,
    ];
  }

  /// Get all lecturers
  List<User> get lecturers {
    return [...supervisors.map((e) => e.user), ...examiners.map((e) => e.user)];
  }

  factory Thesis.fromJson(Map<String, dynamic> json) {
    List<ThesisLecture> supervisors = [];
    List<ThesisLecture> examiners = [];

    for (var e in json['supervisors'] as List<dynamic>) {
      supervisors.add(
        ThesisLecture(
          user: User.fromJson(e['lecture'] as Map<String, dynamic>),
          role: ThesisLectureRole.fromString(e['role'] as String),
          examinerType: e['examiner_type'] != null
              ? ThesisLectureExaminerType.fromString(
                  e['examiner_type'] as String)
              : null,
          proposalDefenseApprovedAt: e['proposal_defense_approved_at'] != null
              ? DateTime.parse(e['proposal_defense_approved_at'] as String)
              : null,
          finalDefenseApprovedAt: e['final_defense_approved_at'] != null
              ? DateTime.parse(e['final_defense_approved_at'] as String)
              : null,
          finalizeApprovedAt: e['finalize_approved_at'] != null
              ? DateTime.parse(e['finalize_approved_at'] as String)
              : null,
        ),
      );
    }

    for (var e in json['examiners'] as List<dynamic>) {
      examiners.add(
        ThesisLecture(
          user: User.fromJson(e['lecture'] as Map<String, dynamic>),
          role: ThesisLectureRole.fromString(e['role'] as String),
          examinerType: e['examiner_type'] != null
              ? ThesisLectureExaminerType.fromString(
                  e['examiner_type'] as String)
              : null,
          proposalDefenseApprovedAt: e['proposal_defense_approved_at'] != null
              ? DateTime.parse(e['proposal_defense_approved_at'] as String)
              : null,
          finalDefenseApprovedAt: e['final_defense_approved_at'] != null
              ? DateTime.parse(e['final_defense_approved_at'] as String)
              : null,
          finalizeApprovedAt: e['finalize_approved_at'] != null
              ? DateTime.parse(e['finalize_approved_at'] as String)
              : null,
        ),
      );
    }

    return Thesis(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      supervisorId: json['supervisor_id'] as String,
      title: json['title'] as String,
      abstract: json['abstract'] as String,
      researchField: json['research_field'] as String,
      status: ThesisStatus.fromString(json['status'] as String),
      submissionDate: DateTime.parse(json['submission_date'] as String),
      completionDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      draftDocumentUrl: json['draft_document_url'] as String?,
      finalDocumentUrl: json['final_document_url'] as String?,
      isProposalReady: json['is_proposal_ready'] as bool,
      isFinalExamReady: json['is_final_exam_ready'] as bool,
      student: User.fromJson(json['student'] as Map<String, dynamic>),
      supervisors: supervisors,
      examiners: examiners,
      mainSupervisor:
          User.fromJson(json['main_supervisor'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'supervisor_id': supervisorId,
      'title': title,
      'abstract': abstract,
      'research_field': researchField,
      'status': status.name,
      'submission_date': submissionDate.toIso8601String(),
      'completed_date': completionDate?.toIso8601String(),
      'draft_document_url': draftDocumentUrl,
      'final_document_url': finalDocumentUrl,
      'is_proposal_ready': isProposalReady,
      'is_final_exam_ready': isFinalExamReady,
      'student': student.toJson(),
      'main_supervisor': mainSupervisor.toJson(),
      'supervisors': supervisors.map((e) => e.toJson()).toList(),
      'examiners': examiners.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Thesis copyWith({
    String? id,
    String? studentId,
    String? supervisorId,
    String? title,
    String? abstract,
    String? researchField,
    ThesisStatus? status,
    DateTime? submissionDate,
    DateTime? completionDate,
    String? draftDocumentUrl,
    String? finalDocumentUrl,
    bool? isProposalReady,
    bool? isFinalExamReady,
    User? student,
    User? mainSupervisor,
    List<ThesisLecture>? supervisors,
    List<ThesisLecture>? examiners,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Thesis(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      supervisorId: supervisorId ?? this.supervisorId,
      title: title ?? this.title,
      abstract: abstract ?? this.abstract,
      researchField: researchField ?? this.researchField,
      status: status ?? this.status,
      submissionDate: submissionDate ?? this.submissionDate,
      completionDate: completionDate ?? this.completionDate,
      draftDocumentUrl: draftDocumentUrl ?? this.draftDocumentUrl,
      finalDocumentUrl: finalDocumentUrl ?? this.finalDocumentUrl,
      isProposalReady: isProposalReady ?? this.isProposalReady,
      isFinalExamReady: isFinalExamReady ?? this.isFinalExamReady,
      student: student ?? this.student,
      mainSupervisor: mainSupervisor ?? this.mainSupervisor,
      supervisors: supervisors ?? this.supervisors,
      examiners: examiners ?? this.examiners,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ThesisProgress {
  final double totalProgress;
  final ProgressDetails details;

  ThesisProgress({required this.totalProgress, required this.details});

  factory ThesisProgress.fromJson(Map<String, dynamic> json) {
    return ThesisProgress(
      totalProgress: double.parse(json['total_progress'].toString()),
      details:
          ProgressDetails.fromJson(json['details'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_progress': totalProgress,
      'details': details.toJson(),
    };
  }
}

class ProgressDetails {
  final double initialPhase;
  final double proposalPhase;
  final double researchPhase;
  final double finalPhase;

  ProgressDetails({
    required this.initialPhase,
    required this.proposalPhase,
    required this.researchPhase,
    required this.finalPhase,
  });

  factory ProgressDetails.fromJson(Map<String, dynamic> json) {
    return ProgressDetails(
      initialPhase: double.parse(json['initial_phase'].toString()),
      proposalPhase: double.parse(json['proposal_phase'].toString()),
      researchPhase: double.parse(json['research_phase'].toString()),
      finalPhase: double.parse(json['final_phase'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'initial_phase': initialPhase,
      'proposal_phase': proposalPhase,
      'research_phase': researchPhase,
      'final_phase': finalPhase,
    };
  }
}

enum ThesisLectureRole {
  supervisor('Supervisor'),
  examiner('Examiner');

  final String name;
  const ThesisLectureRole(this.name);

  static ThesisLectureRole fromString(String value) {
    return ThesisLectureRole.values.firstWhere((e) => e.name == value);
  }
}

enum ThesisLectureExaminerType {
  proposalDefenseExaminer('ProposalDefenseExaminer'),
  finalDefenseExaminer('FinalDefenseExaminer');

  final String name;
  const ThesisLectureExaminerType(this.name);

  static ThesisLectureExaminerType fromString(String value) {
    return ThesisLectureExaminerType.values.firstWhere((e) => e.name == value);
  }
}

class ThesisLecture {
  final User user;
  final ThesisLectureRole role;
  final ThesisLectureExaminerType? examinerType;
  final DateTime? proposalDefenseApprovedAt;
  final DateTime? finalDefenseApprovedAt;
  final DateTime? finalizeApprovedAt;

  ThesisLecture({
    required this.user,
    required this.role,
    this.examinerType,
    this.proposalDefenseApprovedAt,
    this.finalDefenseApprovedAt,
    this.finalizeApprovedAt,
  });

  factory ThesisLecture.fromJson(Map<String, dynamic> json) {
    return ThesisLecture(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      role: ThesisLectureRole.fromString(json['role'] as String),
      examinerType: json['examiner_type'] != null
          ? ThesisLectureExaminerType.fromString(
              json['examiner_type'] as String)
          : null,
      proposalDefenseApprovedAt: json['proposal_defense_approved_at'] != null
          ? DateTime.parse(json['proposal_defense_approved_at'] as String)
          : null,
      finalDefenseApprovedAt: json['final_defense_approved_at'] != null
          ? DateTime.parse(json['final_defense_approved_at'] as String)
          : null,
      finalizeApprovedAt: json['finalize_approved_at'] != null
          ? DateTime.parse(json['finalize_approved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'role': role.name,
      'examiner_type': examinerType?.name,
      'proposal_defense_approved_at':
          proposalDefenseApprovedAt?.toIso8601String(),
      'final_defense_approved_at': finalDefenseApprovedAt?.toIso8601String(),
      'finalize_approved_at': finalizeApprovedAt?.toIso8601String(),
    };
  }
}
