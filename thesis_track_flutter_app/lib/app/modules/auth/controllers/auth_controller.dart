import 'package:get/get.dart';
import 'package:thesis_track_flutter_app/app/core/storage_service.dart';
import 'package:thesis_track_flutter_app/app/data/models/user_model.dart';
import 'package:thesis_track_flutter_app/app/data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final _user = Rxn<User>();
  final _isLoading = false.obs;
  final _supervisors = <User>[].obs;
  final _users = <User>[].obs;

  User? get user => _user.value;
  bool get isLoading => _isLoading.value;
  List<User> get supervisors => _supervisors;
  List<User> get users => _users;

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    final userData = StorageService.getUser();
    if (userData != null) {
      _user.value = User.fromJson(userData);
    }
  }

  Future<String?> getSupervisors() async {
    try {
      _isLoading.value = true;
      final result = await _authRepository.getSupervisors();
      return result.fold(
        (failure) => failure.message,
        (supervisors) {
          _supervisors.value = supervisors;
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
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

          data.user.role = data.role; // Add role to user

          await StorageService.setToken(accessToken);
          await StorageService.setRefreshToken(refreshToken);
          await StorageService.setUser(data.user.toJson());
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
        role: role,
        nidn: nidn,
        department: department,
        nim: nim,
        year: year,
      );

      return result.fold(
        (failure) => failure.message,
        (data) async {
          final accessToken = data['access_token'] as String;
          final refreshToken = data['refresh_token'] as String;
          final userData = data['user'] as Map<String, dynamic>;

          await StorageService.setToken(accessToken);
          await StorageService.setRefreshToken(refreshToken);
          await StorageService.setUser(userData);
          _user.value = User.fromJson(userData);
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await StorageService.clearAuthData();
      _user.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      // Handle error
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

  Future<String?> getAllUsers() async {
    try {
      _isLoading.value = true;
      final result = await _authRepository.getAllUsers();
      return result.fold(
        (failure) => failure.message,
        (users) {
          _users.value = users;
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      _isLoading.value = true;
      final result = await _authRepository.updateUserRole(
        userId: userId,
        role: role,
      );
      return result.fold(
        (failure) => failure.message,
        (updatedUser) {
          final index = _users.indexWhere((u) => u.id == userId);
          if (index != -1) {
            _users[index] = updatedUser;
          }
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<String?> deleteUser(String userId) async {
    try {
      _isLoading.value = true;
      final result = await _authRepository.deleteUser(userId);
      return result.fold(
        (failure) => failure.message,
        (_) {
          _users.removeWhere((u) => u.id == userId);
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
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
          // Update user in users list if exists
          final index = _users.indexWhere((u) => u.id == id);
          if (index != -1) {
            _users[index] = student;
          }
          return null;
        },
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
