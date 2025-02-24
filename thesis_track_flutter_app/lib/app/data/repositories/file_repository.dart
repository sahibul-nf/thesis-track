import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import 'package:thesis_track_flutter_app/app/core/api_service.dart';
import 'package:thesis_track_flutter_app/app/core/failures.dart';

class FileRepository {
  final ApiService _apiService = ApiService();

  Future<Either<Failure, String>> uploadThesisDraft(
      String thesisId, File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = dio.FormData.fromMap({
        'document': await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        '/documents/thesis/$thesisId/draft',
        data: formData,
        options: dio.Options(
          contentType: 'multipart/form-data',
        ),
      );

      return Right(response.data['url'] as String);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> uploadThesisFinal(
      String thesisId, File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = dio.FormData.fromMap({
        'document': await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        '/documents/thesis/$thesisId/final',
        data: formData,
        options: dio.Options(
          contentType: 'multipart/form-data',
        ),
      );

      return Right(response.data['url'] as String);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> uploadProgressDocument(
      String progressId, File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = dio.FormData.fromMap({
        'document': await dio.MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.post(
        '/documents/progress/$progressId',
        data: formData,
        options: dio.Options(
          contentType: 'multipart/form-data',
        ),
      );

      return Right(response.data['url'] as String);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> deleteDocument(String url) async {
    try {
      await _apiService.delete('/documents', data: {'url': url});
      return const Right(unit);
    } on dio.DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
