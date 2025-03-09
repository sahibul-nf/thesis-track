import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_track_flutter_app/app/core/route_guard.dart';
import 'package:thesis_track_flutter_app/app/data/models/progress_model.dart';
import 'package:thesis_track_flutter_app/app/data/models/thesis_model.dart';
import 'package:thesis_track_flutter_app/app/main_view.dart';
import 'package:thesis_track_flutter_app/app/modules/admin/screens/documents_screen.dart';
import 'package:thesis_track_flutter_app/app/modules/admin/screens/user_management_screen.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/screens/screens.dart';
import 'package:thesis_track_flutter_app/app/modules/home/screens/screens.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/screens/screens.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/screens.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/thesis_screen.dart';
import 'package:thesis_track_flutter_app/app/widgets/raw_dialog_page.dart';

abstract class RouteLocation {
  static const String home = '/';
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';

  // Thesis Routes
  static const String myThesis = '/thesis/me';
  static const String thesis = '/thesis';
  static const String thesisDetail = '/thesis/:id';
  static const String thesisCreate = '/thesis/create';
  static const String thesisDocuments = '/thesis/:id/documents';

  // Progress Routes
  static const String progress = '/progress';
  static const String progressDetail = '/progress/:id';
  static const String progressCreate = 'progress/thesis/:thesisId/create';
  static const String progressList = '/progress/thesis/:thesisId';

  // Admin Routes
  static const String userManagement = '/admin/users';
  static const String documents = '/admin/docs';

  /// Helper methods
  static String toThesisDetail(String thesisId) => '$thesis/$thesisId';
  static String toProgressDetail(String progressId) => '$progress/$progressId';
  static String toProgressCreate(String thesisId) =>
      '$myThesis/progress/thesis/$thesisId/create';
  static String toProgressList(String thesisId) => '$progress/thesis/$thesisId';
  static String toThesisDocuments(String thesisId) =>
      '$thesis/$thesisId/documents';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteLocation.home,
    redirect: RouteGuard.handle,
    errorBuilder: (context, state) => const RouteErrorScreen(
      message: 'The requested page could not be found.',
    ),
    routes: [
      // Auth Routes
      GoRoute(
        path: RouteLocation.login,
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: RouteLocation.register,
        name: 'register',
        builder: (context, state) => RegisterScreen(),
      ),

      // Main Shell Route
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainView(child: child),
        routes: [
          // Home Route
          GoRoute(
            path: RouteLocation.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
            routes: const [],
          ),
          // Thesis Routes
          GoRoute(
            path: RouteLocation.myThesis,
            name: 'my_thesis',
            builder: (context, state) => const ThesisScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: RouteLocation.progressCreate,
                name: 'progress_create',
                pageBuilder: (context, state) {
                  final thesis = state.extra as Thesis;
                  return RawDialogPage(
                    barrierDismissible: true,
                    barrierColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: ProgressCreateScreen(thesis: thesis),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: RouteLocation.thesis,
            name: 'browse_theses',
            builder: (context, state) => const ThesisScreen(),
          ),
          GoRoute(
            path: RouteLocation.thesisDetail,
            name: 'thesis_detail',
            builder: (context, state) {
              final thesis = state.extra as Thesis?;
              if (thesis == null) {
                return const Center(
                  child: Text('Thesis not found'),
                );
              }
              return ThesisDetailScreen(thesis: thesis);
            },
          ),
          GoRoute(
            path: RouteLocation.thesisCreate,
            name: 'thesis_create',
            builder: (context, state) => const ThesisCreateScreen(),
          ),

          // Progress Routes
          GoRoute(
            path: RouteLocation.progressDetail,
            name: 'progress_detail',
            builder: (context, state) {
              final progress = state.extra as ProgressModel;
              return ProgressDetailScreen(progress: progress);
            },
          ),
          GoRoute(
            path: RouteLocation.progressList,
            name: 'progress_list',
            builder: (context, state) {
              final thesis = state.extra as Thesis;
              return ProgressListScreen(thesis: thesis);
            },
          ),

          // Documents Route
          GoRoute(
            path: RouteLocation.thesisDocuments,
            name: 'thesis_documents',
            builder: (context, state) =>
                ThesisDocumentsScreen(thesis: state.extra as Thesis),
          ),

          // Documents Route
          GoRoute(
              path: RouteLocation.documents,
              name: 'documents_management',
              builder: (context, state) => const DocumentsScreen()),

          // Admin Routes
          GoRoute(
            path: RouteLocation.userManagement,
            name: 'user_management',
            builder: (context, state) => const UserManagementScreen(),
          ),
        ],
      ),
    ],
  );
}
