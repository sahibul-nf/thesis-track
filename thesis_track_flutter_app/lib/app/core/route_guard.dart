import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
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
    final user = RoleGuard.getCurrentUser();
    if (user == null) return null;

    final location = state.matchedLocation;

    // Student-specific routes
    if (!RoleGuard.canCreateThesis() && location == '/thesis/create') {
      return '/';
    }

    if (!RoleGuard.canAddProgress() && location.contains('/progress/create')) {
      return '/';
    }

    if (!RoleGuard.canUploadDocuments() && location.contains('/documents')) {
      return '/';
    }

    // Lecturer-specific routes
    // if (!RoleGuard.canReviewProgress() && location.contains('/review')) {
    //   return '/';
    // }

    // if (!RoleGuard.canApproveThesis() && location.contains('/approve')) {
    //   return '/';
    // }

    // Admin-specific routes
    if (!RoleGuard.canManageUsers() && location.startsWith('/admin')) {
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
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .errorContainer
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.warning_2,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Access Denied',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Iconsax.home),
                  label: const Text('Back to Home'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 48),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
