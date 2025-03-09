import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_track_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:thesis_track_app/features/home/presentation/screens/admin_home_screen.dart';
import 'package:thesis_track_app/features/home/presentation/screens/admin_reports_screen.dart';
import 'package:thesis_track_app/features/home/presentation/screens/admin_settings_screen.dart';
import 'package:thesis_track_app/features/home/presentation/screens/admin_theses_screen.dart';
import 'package:thesis_track_app/features/home/presentation/screens/admin_users_screen.dart';
import 'package:thesis_track_app/features/thesis/domain/models/thesis_model.dart';
import 'package:thesis_track_app/features/thesis/presentation/screens/create_thesis_screen.dart';
import 'package:thesis_track_app/features/thesis/presentation/screens/thesis_detail_screen.dart';
import 'package:thesis_track_app/features/thesis/presentation/screens/thesis_screen.dart';
import 'package:thesis_track_app/features/home/presentation/screens/home_screen.dart';
import 'package:thesis_track_app/features/home/presentation/screens/student_home_screen.dart';
import 'package:thesis_track_app/features/home/presentation/screens/lecturer_home_screen.dart';

class AppRoutes {
  static String _getHomeRouteForRole(String role) {
    switch (role) {
      case 'student':
        return '/student/home';
      case 'lecturer':
        return '/lecturer/home';
      case 'admin':
        return '/admin/home';
      default:
        return '/';
    }
  }

  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authController = Get.find<AuthController>();
      final isAuthenticated = authController.isAuthenticated.value;
      final isOnAuthRoute = state.path == '/login' || state.path == '/register';
      final userRole = authController.userRole.value;

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isOnAuthRoute) {
        return '/login';
      }

      // Redirect authenticated users from auth routes to their respective home screens
      if (isAuthenticated && isOnAuthRoute) {
        return _getHomeRouteForRole(userRole);
      }

      // Role-based route protection
      if (isAuthenticated) {
        final requestedPath = state.path ?? '';
        
        // Admin routes protection
        if (requestedPath.startsWith('/admin') && userRole != 'admin') {
          return _getHomeRouteForRole(userRole);
        }

        // Lecturer routes protection
        if (requestedPath.startsWith('/lecturer') && userRole != 'lecturer') {
          return _getHomeRouteForRole(userRole);
        }

        // Student routes protection
        if (requestedPath.startsWith('/student') && userRole != 'student') {
          return _getHomeRouteForRole(userRole);
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/student/home',
        name: 'student_home',
        builder: (context, state) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: '/lecturer/home',
        name: 'lecturer_home',
        builder: (context, state) => const LecturerHomeScreen(),
      ),
      GoRoute(
        path: '/admin/home',
        name: 'admin_home',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: '/admin/theses',
        name: 'admin_theses',
        builder: (context, state) => const AdminThesesScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin_settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        name: 'admin_reports',
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/thesis',
        name: 'thesis',
        builder: (context, state) => const ThesisScreen(),
      ),
      GoRoute(
        path: '/thesis/detail',
        name: 'thesis_detail',
        builder: (context, state) {
          final thesis = state.extra as ThesisModel;
          return ThesisDetailScreen(thesis: thesis);
        },
      ),
      GoRoute(
        path: '/thesis/create',
        name: 'thesis_create',
        builder: (context, state) => const CreateThesisScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
}

// Placeholder screens - These will be replaced with actual screen implementations
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Splash Screen')));
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login Screen')));
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Register Screen')));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile Screen')));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('404 - Page Not Found')));
}

 String _getHomeRouteForRole(String role) {
    switch (role) {
      case 'student':
        return '/student/home';
      case 'lecturer':
        return '/lecturer/home';
      case 'admin':
        return '/admin/home';
      default:
        return '/';
    }
  }