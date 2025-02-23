import 'dart:io';

import 'package:dio/dio.dart';
import 'package:thesis_track_app/core/config/app_config.dart';
import 'package:thesis_track_app/features/document/domain/repository/document_repository.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final Dio _dio;

  DocumentRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<String> uploadDraftDocument(String thesisId, File document) async {
    try {
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(
          document.path,
          filename: document.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '${AppConfig.fullApiUrl}${AppConfig.endpoints.document.uploadDraft(thesisId)}',
        data: formData,
      );

      return response.data['url'];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Network timeout while uploading final document');
      } else if (e.response?.statusCode == 413) {
        throw Exception('Final document size exceeds the allowed limit');
      } else if (e.response?.statusCode == 415) {
        throw Exception('Invalid file type for final document');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to upload final document');
    } catch (e) {
      throw Exception(
          'Unexpected error while uploading final document: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadFinalDocument(String thesisId, File document) async {
    try {
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(
          document.path,
          filename: document.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '${AppConfig.fullApiUrl}${AppConfig.endpoints.document.uploadFinal(thesisId)}',
        data: formData,
      );

      return response.data['url'];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('Network timeout while uploading final document');
      } else if (e.response?.statusCode == 413) {
        throw Exception('Final document size exceeds the allowed limit');
      } else if (e.response?.statusCode == 415) {
        throw Exception('Invalid file type for final document');
      }
      throw Exception(
          e.response?.data['message'] ?? 'Failed to upload final document');
    } catch (e) {
      throw Exception(
          'Unexpected error while uploading final document: ${e.toString()}');
    }
  }
}
