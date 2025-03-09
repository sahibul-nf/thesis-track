import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

class Comment {
  final String id;
  final String progressId;
  final String userId;
  final String userType;
  final String? parentId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> replies;
  final User user;

  Comment({
    required this.id,
    required this.progressId,
    required this.userId,
    required this.userType,
    this.parentId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
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
              .map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      user: User.fromJson(json['user'] as Map<String, dynamic>, role: json['user_type'] as String),
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
      'replies': replies.map((e) => e.toJson()).toList(),
      'user': user.toJson(),
    };
  }

  Comment copyWith({
    String? id,
    String? progressId,
    String? userId,
    String? userType,
    String? parentId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Comment>? replies,
    User? user,
  }) {
    return Comment(
      id: id ?? this.id,
      progressId: progressId ?? this.progressId,
      userId: userId ?? this.userId,
      userType: userType ?? this.userType,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replies: replies ?? this.replies,
      user: user ?? this.user,
    );
  }
}
