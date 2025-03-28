import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thesis_track_flutter_app/app/core/api_service.dart';
import 'package:thesis_track_flutter_app/app/core/failures.dart';
import 'package:thesis_track_flutter_app/app/data/models/comment_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';

class ProgressRepository {
  final ApiService _apiService = ApiService();

  Future<Either<Failure, List<ProgressModel>>> getProgressesByThesis(
      String thesisId) async {
    try {
      final response = await _apiService.get('/progress/thesis/$thesisId');
      final List<dynamic> data = response.data['data'];
      return Right(data.map((e) => ProgressModel.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<ProgressModel>>> getProgressesByReviewer(
      String thesisId) async {
    try {
      final response =
          await _apiService.get('/progress/thesis/$thesisId/assignee');
      final List<dynamic> data = response.data['data'];
      return Right(data.map((e) => ProgressModel.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProgressModel>> getProgressById(String id) async {
    try {
      final response = await _apiService.get('/progress/$id');
      return Right(ProgressModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProgressModel>> addProgress({
    required String thesisId,
    required String reviewerId,
    required String progressDescription,
    String? documentUrl,
  }) async {
    try {
      final response = await _apiService.post(
        '/progress',
        data: {
          'thesis_id': thesisId,
          'reviewer_id': reviewerId,
          'progress_description': progressDescription,
          'document_url': documentUrl,
        },
      );
      return Right(ProgressModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ProgressModel>> updateProgress({
    required String id,
    required String progressDescription,
    String? documentUrl,
  }) async {
    try {
      final response = await _apiService.put(
        '/progress/$id',
        data: {
          'progress_description': progressDescription,
          'document_url': documentUrl,
        },
      );
      return Right(ProgressModel.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, ({Comment comment, ProgressModel progress})>>
      reviewProgress({
    required String progressId,
    required String comment,
    String? parentId,
  }) async {
    try {
      final response = await _apiService.post(
        '/progress/$progressId/review',
        data: {
          'content': comment,
          'parent_id': parentId,
        },
      );
      
      return Right((
        comment: Comment.fromJson(response.data['data']['comment']),
        progress: ProgressModel.fromJson(response.data['data']['progress']),
      ));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<Comment>>> getCommentsByProgress(
      String progressId) async {
    try {
      final response = await _apiService.get('/progress/$progressId/comments');
      final List<dynamic> data = response.data['data'];
      return Right(data.map((e) => Comment.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Comment>> addComment({
    required String progressId,
    required String content,
    String? parentId,
  }) async {
    try {
      final response = await _apiService.post(
        '/progress/$progressId/comment',
        data: {
          'content': content,
          'parent_id': parentId,
        },
      );
      return Right(Comment.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
