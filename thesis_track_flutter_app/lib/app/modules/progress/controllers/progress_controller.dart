import 'package:get/get.dart' hide Progress;
import 'package:thesis_track_flutter_app/app/data/models/comment_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/progress_repository.dart';

class ProgressController extends GetxController {
  static ProgressController get to => Get.find();

  late final ProgressRepository _progressRepository;

  ProgressController({ProgressRepository? progressRepository}) {
    _progressRepository = progressRepository ?? ProgressRepository();
  }

  final _selectedProgress = Rxn<ProgressModel>();
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  final _isSendingComment = false.obs;

  ProgressModel? get selectedProgress => _selectedProgress.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  bool get isSendingComment => _isSendingComment.value;

  Future<bool> getProgressesByThesis(Thesis thesis) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _progressRepository.getProgressesByThesis(thesis.id);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (progresses) async {
          // assign progresses to thesis
          thesis.progresses.value = progresses;

          // load comments for each progress
          if (progresses.isNotEmpty) {
            for (var progress in progresses) {
              var comments = await getCommentsByProgress(progress.id);
              progress.comments.value = comments;
            }
          }
          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> getProgressesByReviewer(Thesis thesis) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result =
          await _progressRepository.getProgressesByReviewer(thesis.id);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (progresses) async {
          // assign progresses to thesis
          thesis.progresses.value = progresses;

          // load comments for each progress
          if (progresses.isNotEmpty) {
            for (var progress in progresses) {
              var comments = await getCommentsByProgress(progress.id);
              progress.comments.value = comments;
            }
          }
          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> getProgressById(String id) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _progressRepository.getProgressById(id);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (progress) async {
          _selectedProgress.value = progress;

          var comments = await getCommentsByProgress(progress.id);
          progress.comments.value = comments;

          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> addProgress({
    required Thesis thesis,
    required String reviewerId,
    required String progressDescription,
    required String documentUrl,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _progressRepository.addProgress(
        thesisId: thesis.id,
        reviewerId: reviewerId,
        progressDescription: progressDescription.trim(),
        documentUrl: documentUrl.trim(),
      );
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return failure.message;
        },
        (progress) {
          // assign progress to thesis
          thesis.progresses.add(progress);
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> updateProgress({
    required String id,
    required String progressDescription,
    String? documentUrl,
    required ProgressModel progressModel,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _progressRepository.updateProgress(
        id: id,
        progressDescription: progressDescription,
        documentUrl: documentUrl,
      );
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (progress) {
          // final index = _progresses.indexWhere((p) => p.id == id);
          // if (index != -1) {
          //   _progresses[index] = progress;
          // }

          progressModel = progress;
          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> reviewProgress({
    required ProgressModel progress,
    required String comment,
    String? parentId,
  }) async {
    try {
      _isSendingComment.value = true;

      final result = await _progressRepository.reviewProgress(
        progressId: progress.id,
        comment: comment,
        parentId: parentId,
      );
      return result.fold(
        (failure) {
          return failure.message;
        },
        (data) {
          progress.comments.add(data.comment);
          progress.status = data.progress.status;
          return null;
        },
      );
    } finally {
      _isSendingComment.value = false;
    }
  }

  Future<List<Comment>> getCommentsByProgress(String progressId) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result =
          await _progressRepository.getCommentsByProgress(progressId);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return [];
        },
        (comments) {
          return comments;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> addComment({
    required ProgressModel progress,
    required String content,
    String? parentId,
  }) async {
    try {
      _isSendingComment.value = true;

      final result = await _progressRepository.addComment(
        progressId: progress.id,
        content: content,
        parentId: parentId,
      );

      return result.fold(
        (failure) {
          return failure.message;
        },
        (comment) {
          // final progress = _progresses.firstWhere((p) => p.id == progressId);
          // progress.comments.add(comment);

          progress.comments.add(comment);

          return null;
        },
      );
    } finally {
      _isSendingComment.value = false;
    }
  }
}
