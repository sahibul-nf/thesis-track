import 'dart:io';
import 'package:get/get.dart';
import 'package:thesis_track_app/features/thesis/data/repositories/thesis_repository.dart';
import 'package:thesis_track_app/features/thesis/domain/models/thesis_model.dart';
import 'package:thesis_track_app/features/thesis/domain/models/progress_model.dart';

class ThesisController extends GetxController {
  final ThesisRepository _repository;
  final RxList<ThesisModel> theses = <ThesisModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  ThesisController({ThesisRepository? repository})
      : _repository = repository ?? ThesisRepository();

  @override
  void onInit() {
    super.onInit();
    fetchTheses();
  }

  Future<void> fetchTheses() async {
    try {
      isLoading.value = true;
      error.value = '';
      theses.value = await _repository.getAllTheses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createThesis({
    required String title,
    required String abstract,
    required String researchField,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _repository.submitThesis(
        title: title,
        abstract: abstract,
        researchField: researchField,
      );
      await fetchTheses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateThesis(String id, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _repository.updateThesis(id, data);
      await fetchTheses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignExaminer(String thesisId, String lectureId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _repository.assignExaminer(thesisId, lectureId);
      await fetchTheses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignSupervisor(String thesisId, String lectureId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _repository.assignSupervisor(thesisId, lectureId);
      await fetchTheses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveThesis(String thesisId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _repository.approveThesis(thesisId);
      await fetchTheses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsCompleted(String thesisId) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _repository.markAsCompleted(thesisId);
      await fetchTheses();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<ProgressModel> addProgress({
    required String thesisId,
    required String reviewerId,
    required String progressDescription,
    String? documentUrl,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      final progress = await _repository.addProgress(
        thesisId: thesisId,
        reviewerId: reviewerId,
        progressDescription: progressDescription,
        documentUrl: documentUrl,
      );
      await fetchTheses();
      return progress;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<ProgressModel> getProgress(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      return await _repository.getProgress(id);
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProgressModel>> getProgressesByThesis(String thesisId) async {
    try {
      isLoading.value = true;
      error.value = '';
      return await _repository.getProgressesByThesis(thesisId);
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ProgressModel>> getProgressesByReviewer(String reviewerId) async {
    try {
      isLoading.value = true;
      error.value = '';
      return await _repository.getProgressesByReviewer(reviewerId);
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProgress({
    required String id,
    required String progressDescription,
    String? documentUrl,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _repository.updateProgress(
        id: id,
        progressDescription: progressDescription,
        documentUrl: documentUrl,
      );
      await fetchTheses();
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> uploadDraftDocument(String thesisId, File document) async {
    try {
      isLoading.value = true;
      error.value = '';
      final documentUrl = await _repository.uploadDraftDocument(thesisId, document);
      await fetchTheses();
      return documentUrl;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> uploadFinalDocument(String thesisId, File document) async {
    try {
      isLoading.value = true;
      error.value = '';
      final documentUrl = await _repository.uploadFinalDocument(thesisId, document);
      await fetchTheses();
      return documentUrl;
    } catch (e) {
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
