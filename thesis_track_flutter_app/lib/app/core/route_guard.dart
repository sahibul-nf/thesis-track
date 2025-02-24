import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_track_flutter_app/app/core/role_guard.dart';
import 'package:thesis_track_flutter_app/app/core/storage_service.dart';

class RouteGuard {
  static String? handleAuth(BuildContext context, GoRouterState state) {
    final isLoggedIn = StorageService.isLoggedIn();
    final isAuthRoute = state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    if (isLoggedIn && isAuthRoute) {
      return '/';
    }

    return null;
  }

  static String? handleRole(BuildContext context, GoRouterState state) {
    final role = RoleGuard.getCurrentRole();
    if (role == null) return null;

    // Student-specific routes
    if (!RoleGuard.canCreateThesis() &&
        (state.matchedLocation == '/thesis/create')) {
      return '/';
    }

    if (!RoleGuard.canAddProgress() &&
        state.matchedLocation.contains('/progress/create')) {
      return '/';
    }

    if (!RoleGuard.canUploadDocuments() &&
        state.matchedLocation.contains('/documents')) {
      return '/';
    }

    // Lecturer-specific routes
    if (!RoleGuard.canReviewProgress() &&
        state.matchedLocation.contains('/review')) {
      return '/';
    }

    if (!RoleGuard.canApproveThesis() &&
        state.matchedLocation.contains('/approve')) {
      return '/';
    }

    // Admin-specific routes
    if (!RoleGuard.canManageUsers() &&
        state.matchedLocation.startsWith('/admin')) {
      return '/';
    }

    return null;
  }

  static String? handle(BuildContext context, GoRouterState state) {
    final authRedirect = handleAuth(context, state);
    if (authRedirect != null) return authRedirect;

    final roleRedirect = handleRole(context, state);
    if (roleRedirect != null) return roleRedirect;

    return null;
  }
}

class RouteErrorScreen extends StatelessWidget {
  final String message;

  const RouteErrorScreen({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Access Denied',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
