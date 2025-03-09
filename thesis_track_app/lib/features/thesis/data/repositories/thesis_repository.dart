import 'dart:io';
import 'package:dio/dio.dart';
import 'package:thesis_track_app/features/thesis/domain/models/thesis_model.dart';
import 'package:thesis_track_app/features/thesis/domain/models/progress_model.dart';
import 'package:thesis_track_app/features/thesis/domain/repository/thesis_repository.dart';
import 'package:thesis_track_app/features/document/data/repository/document_repository_impl.dart';

class ThesisRepository implements ThesisRepository {
  final Dio _dio;
  final DocumentRepositoryImpl _documentRepository;

  ThesisRepository({Dio? dio})
      : _dio = dio ?? Dio(),
        _documentRepository = DocumentRepositoryImpl(dio: dio);

  Exception _handleDioError(DioException e) {
    return Exception(e.response?.data['message'] ?? e.message);
  }

  @override
  Future<List<ThesisModel>> getAllTheses() async {
    try {
      final response = await _dio.get('/api/theses');
      return (response.data['data'] as List)
          .map((json) => ThesisModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ThesisModel> getThesis(String id) async {
    try {
      final response = await _dio.get('/api/theses/$id');
      return ThesisModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ThesisModel> submitThesis({
    required String title,
    required String abstract,
    required String researchField,
  }) async {
    try {
      final response = await _dio.post('/api/theses', data: {
        'title': title,
        'abstract': abstract,
        'research_field': researchField,
      });
      return ThesisModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> assignExaminer(String thesisId, String lectureId) async {
    try {
      await _dio.post('/api/theses/$thesisId/examiners', data: {
        'lecture_id': lectureId,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> assignSupervisor(String thesisId, String lectureId) async {
    try {
      await _dio.post('/api/theses/$thesisId/supervisors', data: {
        'lecture_id': lectureId,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> approveThesis(String thesisId) async {
    try {
      await _dio.post('/api/theses/$thesisId/approve');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> markAsCompleted(String thesisId) async {
    try {
      await _dio.post('/api/theses/$thesisId/complete');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProgressModel> addProgress({
    required String thesisId,
    required String reviewerId,
    required String progressDescription,
    String? documentUrl,
  }) async {
    try {
      final response = await _dio.post('/api/theses/$thesisId/progresses', data: {
        'reviewer_id': reviewerId,
        'progress_description': progressDescription,
        if (documentUrl != null) 'document_url': documentUrl,
      });
      return ProgressModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProgressModel> getProgress(String id) async {
    try {
      final response = await _dio.get('/api/progresses/$id');
      return ProgressModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProgressModel>> getProgressesByThesis(String thesisId) async {
    try {
      final response = await _dio.get('/api/theses/$thesisId/progresses');
      return (response.data['data'] as List)
          .map((json) => ProgressModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProgressModel>> getProgressesByReviewer(String reviewerId) async {
    try {
      final response = await _dio.get('/api/reviewers/$reviewerId/progresses');
      return (response.data['data'] as List)
          .map((json) => ProgressModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> updateProgress({
    required String id,
    required String progressDescription,
    String? documentUrl,
  }) async {
    try {
      await _dio.put('/api/progresses/$id', data: {
        'progress_description': progressDescription,
        if (documentUrl != null) 'document_url': documentUrl,
      });
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> reviewProgress({
    required String progressId,
    required String comment,
    String? parentId,
  }) async {
    try {
      final response = await _dio.post('/api/progresses/$progressId/comments', data: {
        'comment': comment,
        if (parentId != null) 'parent_id': parentId,
      });
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CommentModel>> getCommentsByProgress(String progressId) async {
    try {
      final response = await _dio.get('/api/progresses/$progressId/comments');
      return (response.data['data'] as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<String> uploadDraftDocument(String thesisId, File document) async {
    return await _documentRepository.uploadDraftDocument(thesisId, document);
  }

  Future<String> uploadFinalDocument(String thesisId, File document) async {
    return await _documentRepository.uploadFinalDocument(thesisId, document);
  }
}
