import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:thesis_track_flutter_app/app/data/models/comment_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

class ProgressModel {
  final String id;
  final String thesisId;
  final String reviewerId;
  final String progressDescription;
  final String? documentUrl;
  RxString status;
  final DateTime achievementDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User reviewer;

  ProgressModel({
    required this.id,
    required this.thesisId,
    required this.reviewerId,
    required this.progressDescription,
    this.documentUrl,
    required this.status,
    required this.achievementDate,
    required this.createdAt,
    required this.updatedAt,
    required this.reviewer,
  });
  
  RxList<Comment> comments = <Comment>[].obs;

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] as String,
      thesisId: json['thesis_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      progressDescription: json['progress_description'] as String,
      documentUrl: json['document_url'] as String?,
      status: RxString(json['status'] as String),
      achievementDate: DateTime.parse(json['achievement_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reviewer: User.fromJson(json['reviewer'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thesis_id': thesisId,
      'reviewer_id': reviewerId,
      'progress_description': progressDescription,
      'document_url': documentUrl,
      'status': status.value,
      'achievement_date': achievementDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'reviewer': reviewer.toJson(),
    };
  }

  ProgressModel copyWith({
    String? id,
    String? thesisId,
    String? reviewerId,
    String? progressDescription,
    String? documentUrl,
    RxString? status,
    DateTime? achievementDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? reviewer,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      thesisId: thesisId ?? this.thesisId,
      reviewerId: reviewerId ?? this.reviewerId,
      progressDescription: progressDescription ?? this.progressDescription,
      documentUrl: documentUrl ?? this.documentUrl,
      status: status ?? this.status,
      achievementDate: achievementDate ?? this.achievementDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewer: reviewer ?? this.reviewer,
    );
  }
}
