import 'package:thesis_track_app/features/progress/domain/entities/progress.dart';

abstract class ProgressRepository {
  Future<List<Progress>> getProgressList();
  Future<Progress> getProgress(String id);
  Future<Progress> createProgress(String thesisId, String description);
  Future<Progress> updateProgress(String id, String description);
  Future<void> uploadDocument(String progressId, String filePath);
}