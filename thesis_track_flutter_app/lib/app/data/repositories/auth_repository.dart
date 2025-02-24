import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:thesis_track_flutter_app/app/core/api_service.dart';
import 'package:thesis_track_flutter_app/app/core/failures.dart';
import 'package:thesis_track_flutter_app/app/data/models/auth_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Either<Failure, AuthData>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'];
      final authData = AuthData.fromJson(data);

      return Right(authData);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? nidn,
    required String department,
    String? nim,
    String? year,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': role,
          'nidn': nidn,
          'department': department,
          'nim': nim,
          'year': year,
        },
      );

      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> refreshToken(
      String refreshToken) async {
    try {
      final response = await _apiService.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      return Right(response.data);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<User>>> getSupervisors() async {
    try {
      final response = await _apiService.get('/users/supervisors');
      final List<dynamic> data = response.data['data'];
      return Right(data.map((e) => User.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<User>>> getAllUsers() async {
    try {
      final response = await _apiService.get('/users');
      final List<dynamic> data = response.data['data'];
      return Right(data.map((e) => User.fromJson(e)).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

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
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> deleteUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId');
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> getStudent(String id) async {
    try {
      final response = await _apiService.get('/students/$id');
      return Right(User.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, User>> updateStudent({
    required String id,
    required String name,
    required String email,
    required String nim,
    required String department,
    required String year,
  }) async {
    try {
      final response = await _apiService.put(
        '/students/$id',
        data: {
          'name': name,
          'email': email,
          'nim': nim,
          'department': department,
          'year': year,
        },
      );
      return Right(User.fromJson(response.data['data']));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Server error occurred'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
