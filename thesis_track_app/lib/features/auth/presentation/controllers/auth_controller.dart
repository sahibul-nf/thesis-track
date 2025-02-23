import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080')); // Replace with your API URL
  final _storage = const FlutterSecureStorage();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isAuthenticated = false.obs;
  final userRole = ''.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token != null) {
        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final role = decodedToken['role'] as String?;

        if (role != null) {
          isAuthenticated.value = true;
          userRole.value = role;
        }
      }
    } catch (e) {
      debugPrint('Error checking auth status: $e');
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    error.value = '';

    try {
      isLoading.value = true;

      final response = await dio.post('/auth/login', data: {
        'email': emailController.text,
        'password': passwordController.text,
      });

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['data'];
        await _storage.write(key: 'token', value: token);

        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final role = decodedToken['role'] as String? ?? 'student';

        isAuthenticated.value = true;
        userRole.value = role;

        switch (userRole.value) {
          case 'student':
            context.go('/student/home');
            break;
          case 'lecturer':
            context.go('/lecturer/home');
            break;
          case 'admin':
            context.go('/admin/home');
            break;
          default:
            context.go('/');
        }
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'An error occurred';
        error.value = errorMessage;
      } else {
        error.value = 'Network error. Please check your connection.';
      }
      debugPrint(e.toString());
    } catch (e) {
      error.value = 'An unexpected error occurred.';
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final response = await dio.post('/auth/register', data: {
        'email': emailController.text,
        'password': passwordController.text,
        'name': nameController.text,
      });

      if (response.statusCode == 200 && response.data != null) {
        Get.snackbar(
          'Success',
          'Registration successful! Please login.',
          snackPosition: SnackPosition.TOP,
        );
        context.go('/login');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'Registration failed';
        error.value = errorMessage;
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
        );
      } else {
        error.value = 'Network error. Please check your connection.';
      }
      debugPrint(e.toString());
    } catch (e) {
      error.value = 'An unexpected error occurred.';
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _storage.delete(key: 'token');
      isAuthenticated.value = false;
      userRole.value = '';
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
