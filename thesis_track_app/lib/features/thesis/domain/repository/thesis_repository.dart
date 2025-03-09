import 'package:thesis_track_app/features/thesis/domain/models/thesis_model.dart';
import 'package:thesis_track_app/features/thesis/domain/models/progress_model.dart';

abstract class ThesisRepository {
  // Thesis Management
  Future<ThesisModel> submitThesis({
    required String title,
    required String abstract,
    required String researchField,
  });

  Future<ThesisModel> getThesis(String id);
  Future<List<ThesisModel>> getAllTheses();

  Future<void> assignExaminer(String thesisId, String lectureId);
  Future<void> assignSupervisor(String thesisId, String lectureId);
  Future<void> approveThesis(String thesisId);
  Future<void> markAsCompleted(String thesisId);

  // Progress Management
  Future<ProgressModel> addProgress({
    required String thesisId,
    required String reviewerId,
    required String progressDescription,
    String? documentUrl,
  });

  Future<ProgressModel> getProgress(String id);
  Future<List<ProgressModel>> getProgressesByThesis(String thesisId);
  Future<List<ProgressModel>> getProgressesByReviewer(String thesisId);

  Future<void> updateProgress({
    required String id,
    required String progressDescription,
    String? documentUrl,
  });

  Future<Map<String, dynamic>> reviewProgress({
    required String progressId,
    required String comment,
    String? parentId,
  });

  Future<List<CommentModel>> getCommentsByProgress(String progressId);

  Future<CommentModel> addComment({
    required String progressId,
    required String content,
    String? parentId,
  });

  // Document Management
  Future<String> uploadDraftDocument(String thesisId, dynamic file);
  Future<String> uploadFinalDocument(String thesisId, dynamic file);
}