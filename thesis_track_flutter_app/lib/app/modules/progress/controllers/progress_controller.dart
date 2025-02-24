import 'package:get/get.dart' hide Progress;
import 'package:thesis_track_flutter_app/app/data/models/comment_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/progress_repository.dart';

class ProgressController extends GetxController {
  final ProgressRepository _progressRepository = ProgressRepository();
  final _progresses = <Progress>[].obs;
  final _selectedProgress = Rxn<Progress>();
  final _comments = <Comment>[].obs;
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  List<Progress> get progresses => _progresses;
  Progress? get selectedProgress => _selectedProgress.value;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;

  Future<bool> getProgressesByThesis(String thesisId) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _progressRepository.getProgressesByThesis(thesisId);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (progresses) {
          _progresses.value = progresses;
          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> getProgressesByReviewer(String thesisId) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result =
          await _progressRepository.getProgressesByReviewer(thesisId);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (progresses) {
          _progresses.value = progresses;
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
        (progress) {
          _selectedProgress.value = progress;
          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> addProgress({
    required String thesisId,
    required String reviewerId,
    required String progressDescription,
    String? documentUrl,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _progressRepository.addProgress(
        thesisId: thesisId,
        reviewerId: reviewerId,
        progressDescription: progressDescription,
        documentUrl: documentUrl,
      );
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (progress) {
          _progresses.add(progress);
          return true;
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
          final index = _progresses.indexWhere((p) => p.id == id);
          if (index != -1) {
            _progresses[index] = progress;
          }
          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> reviewProgress({
    required String progressId,
    required String comment,
    String? parentId,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _progressRepository.reviewProgress(
        progressId: progressId,
        comment: comment,
        parentId: parentId,
      );
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (comment) => true,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> getCommentsByProgress(String progressId) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result =
          await _progressRepository.getCommentsByProgress(progressId);
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (comments) {
          _comments.value = comments;
          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> addComment({
    required String progressId,
    required String content,
    String? parentId,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = null;

      final result = await _progressRepository.addComment(
        progressId: progressId,
        content: content,
        parentId: parentId,
      );
      return result.fold(
        (failure) {
          _error.value = failure.message;
          return false;
        },
        (comment) {
          _comments.add(comment);
          return true;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
