import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thesis_track_flutter_app/app/core/api_service.dart';
import 'package:thesis_track_flutter_app/app/core/failures.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

abstract class IAdminRepository {
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, User>> updateUserRole({
    required String userId,
    required String role,
  });
  Future<Either<Failure, Unit>> deleteUser(String userId);
}

class AdminRepository implements IAdminRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final response = await _apiService.get('/users');
      final List<dynamic> students = response.data['data']['students'];
      final List<dynamic> lectures = response.data['data']['lectures'];

      List<User> users = [
        ...students.map((e) => User.fromJson(e, role: 'Student')),
        ...lectures.map((e) => User.fromJson(e, role: 'Lecture')),
      ];

      return Right(users);
    } on DioException catch (e) {
      var errorMessage = e.response?.data['error'];
      return Left(ServerFailure(errorMessage ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      final response = await _apiService.put(
        '/users/$userId/role',
        data: {'role': role},
      );
      return Right(User.fromJson(response.data['data']));
    } on DioException catch (e) {
      var errorMessage = e.response?.data['error'];
      return Left(ServerFailure(errorMessage ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId');
      return const Right(unit);
    } on DioException catch (e) {
      var errorMessage = e.response?.data['error'];
      return Left(ServerFailure(errorMessage ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
