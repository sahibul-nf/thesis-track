import 'package:thesis_track_app/features/auth/domain/models/user_model.dart';

class ProgressModel {
  final String id;
  final String thesisId;
  final String reviewerId;
  final String progressDescription;
  final String? documentUrl;
  final String status;
  final DateTime achievementDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel reviewer;
  final List<CommentModel>? comments;

  const ProgressModel({
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
    this.comments,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'] as String,
      thesisId: json['thesis_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      progressDescription: json['progress_description'] as String,
      documentUrl: json['document_url'] as String?,
      status: json['status'] as String,
      achievementDate: DateTime.parse(json['achievement_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      reviewer: UserModel.fromJson(json['reviewer'] as Map<String, dynamic>),
      comments: json['comments'] != null
          ? (json['comments'] as List<dynamic>)
              .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'thesis_id': thesisId,
      'reviewer_id': reviewerId,
      'progress_description': progressDescription,
      'document_url': documentUrl,
      'status': status,
      'achievement_date': achievementDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'reviewer': reviewer.toJson(),
      'comments': comments?.map((e) => e.toJson()).toList(),
    };
  }
}

class CommentModel {
  final String id;
  final String progressId;
  final String userId;
  final String userType;
  final String? parentId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CommentModel>? replies;
  final UserModel user;

  const CommentModel({
    required this.id,
    required this.progressId,
    required this.userId,
    required this.userType,
    this.parentId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.replies,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      progressId: json['progress_id'] as String,
      userId: json['user_id'] as String,
      userType: json['user_type'] as String,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      replies: json['replies'] != null
          ? (json['replies'] as List<dynamic>)
              .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress_id': progressId,
      'user_id': userId,
      'user_type': userType,
      'parent_id': parentId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'replies': replies?.map((e) => e.toJson()).toList(),
      'user': user.toJson(),
    };
  }
}