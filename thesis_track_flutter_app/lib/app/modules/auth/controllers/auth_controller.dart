import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/core/storage_service.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/auth_repository.dart';

import '../../progress/controllers/progress_controller.dart';
import '../../thesis/controllers/thesis_controller.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthRepository _authRepository = AuthRepository();
  final _user = Rxn<User>();
  final _isLoading = false.obs;

  User? get user => _user.value;
  bool get isLoading => _isLoading.value;  

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    final userData = StorageService.getUser();
    if (userData != null) {
      _user.value = userData;
    }
  }  

  Future<String?> login(String email, String password) async {
    try {
      _isLoading.value = true;
      final result = await _authRepository.login(email, password);

      return result.fold(
        (failure) => failure.message,
        (data) async {
          final accessToken = data.accessToken;
          final refreshToken = data.refreshToken;

          await StorageService.setToken(accessToken);
          await StorageService.setRefreshToken(refreshToken);
          await StorageService.setUser(data.user);
          _user.value = data.user;
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> register({
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
      _isLoading.value = true;
      final result = await _authRepository.register(
        email: email,
        password: password,
        name: name,
        role: role.capitalizeFirst!,
        nidn: nidn,
        department: department,
        nim: nim,
        year: year,
      );

      return result.fold(
        (failure) => failure.message,
        (data) async {
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> logout() async {
    try {
      // Clear data from storage
      await StorageService.clearAuthData();
      _user.value = null;

      // Delete all controllers
      Get.delete<ThesisController>();
      Get.delete<ProgressController>();

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> refreshToken() async {
    try {
      final refreshToken = StorageService.getRefreshToken();
      if (refreshToken == null) {
        return 'No refresh token found';
      }

      final result = await _authRepository.refreshToken(refreshToken);
      return result.fold(
        (failure) => failure.message,
        (data) async {
          final accessToken = data['access_token'] as String;
          final refreshToken = data['refresh_token'] as String;

          await StorageService.setToken(accessToken);
          await StorageService.setRefreshToken(refreshToken);
          return null;
        },
      );
    } catch (e) {
      return e.toString();
    }
  }  

  Future<String?> getStudent(String id) async {
    try {
      _isLoading.value = true;
      final result = await _authRepository.getStudent(id);
      return result.fold(
        (failure) => failure.message,
        (student) {
          // Update user if it's the current user
          if (_user.value?.id == id) {
            _user.value = student;
          }
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> updateStudent({
    required String id,
    required String name,
    required String email,
    required String nim,
    required String department,
    required String year,
  }) async {
    try {
      _isLoading.value = true;
      final result = await _authRepository.updateStudent(
        id: id,
        name: name,
        email: email,
        nim: nim,
        department: department,
        year: year,
      );
      return result.fold(
        (failure) => failure.message,
        (student) {
          // Update user if it's the current user
          if (_user.value?.id == id) {
            _user.value = student;
          }
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
