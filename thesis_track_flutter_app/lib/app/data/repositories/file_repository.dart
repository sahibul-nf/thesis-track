import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
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
      String thesisId, dynamic file) async {
    try {
      // Generate boundary
      const boundary = '---011000010111000001101001';

      late final dio.MultipartFile multipartFile;

      if (kIsWeb) {
        // For web platform, use bytes
        final bytes = file as Uint8List;
        multipartFile = dio.MultipartFile.fromBytes(
          bytes,
          filename: 'document.pdf',
          contentType: dio.DioMediaType('application', 'pdf'),
        );
      } else {
        // For mobile platform, use File
        final fileObj = file as File;
        multipartFile = await dio.MultipartFile.fromFile(
          fileObj.path,
          filename: fileObj.path.split('/').last,
          contentType: dio.DioMediaType('application', 'pdf'),
        );
      }

      final formData = dio.FormData.fromMap({
        'document': multipartFile,
      });

      final response = await _apiService.post(
        '/documents/thesis/$thesisId/final',
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate, br',
            'User-Agent': 'ThesisTrackApp/1.0.0',
            'Connection': 'keep-alive',
            'content-type': 'multipart/form-data; boundary=$boundary',
          },
          contentType: 'multipart/form-data',
          validateStatus: (status) => true,
          followRedirects: false,
          receiveDataWhenStatusError: true,
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final url = response.data['url'] as String?;
        if (url == null) {
          return const Left(ServerFailure('Invalid response from server'));
        }
        return Right(url);
      }

      return Left(
        ServerFailure(response.data['message'] ?? 'Failed to upload document'),
      );
    } on dio.DioException catch (e) {    
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e, stackTrace) {
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
