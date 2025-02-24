import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thesis_track_flutter_app/app/core/api_service.dart';
import 'package:thesis_track_flutter_app/app/core/failures.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

class ThesisRepository {
  final ApiService _apiService = ApiService();

  Future<Either<Failure, List<Thesis>>> getAllTheses() async {
    try {
      final response = await _apiService.get('/theses');
      final List<dynamic> data = response.data['data'];
      return Right(data.map((e) => Thesis.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Thesis>> getThesisById(String id) async {
    try {
      final response = await _apiService.get('/theses/$id');
      return Right(Thesis.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<User>>> getLecturers() async {
    try {
      final response = await _apiService.get('/lecturers');
      final List<dynamic> data = response.data['data'];
      return Right(data.map((e) => User.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Thesis>> createThesis({
    required String title,
    required String abstract,
    required String researchField,
    required String supervisorId,
  }) async {
    try {
      final response = await _apiService.post(
        '/theses',
        data: {
          'title': title,
          'abstract': abstract,
          'research_field': researchField,
          'supervisor_id': supervisorId,
        },
      );
      return Right(Thesis.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> assignSupervisor(
      String thesisId, String lectureId) async {
    try {
      await _apiService.post('/theses/$thesisId/supervisor/$lectureId');
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> assignExaminer(
      String thesisId, String lectureId) async {
    try {
      await _apiService.post('/theses/$thesisId/examiner/$lectureId');
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> approveThesis(String thesisId) async {
    try {
      await _apiService.post('/theses/$thesisId/approve');
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> markAsCompleted(String thesisId) async {
    try {
      await _apiService.post('/theses/$thesisId/complete');
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getThesisProgress(
      String thesisId) async {
    try {
      final response = await _apiService.get('/theses/$thesisId/progress');
      return Right(response.data['data']);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
