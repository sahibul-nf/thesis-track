import 'dart:developer';

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
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/browse_thesis_screen.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/document_preview_screen.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/my_thesis_screen.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/screens.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/top_progress_view.dart';
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
  static const String thesisCreate = 'thesis/create';
  static const String thesisDocuments = '/thesis/:id/documents';
  static const String topProgress = '/top-progress';

  // Progress Routes
  static const String progress = '/progress';
  static const String progressDetail = '/progress/:id';
  static const String progressCreate = 'progress/thesis/:thesisId/create';
  static const String progressList = '/progress/thesis/:thesisId';

  // Admin Routes
  static const String userManagement = '/admin/users';
  static const String documents = '/admin/docs';
  static const String documentPreview = 'documents/preview';

  /// Helper methods
  static String get toCreateThesis => '/$thesisCreate';
  static String toThesisDetail(String thesisId) => '$thesis/$thesisId';
  static String toProgressDetail(String progressId) => '$progress/$progressId';
  static String toProgressCreate(String thesisId) =>
      '$myThesis/progress/thesis/$thesisId/create';
  static String toProgressList(String thesisId) => '$progress/thesis/$thesisId';
  static String toThesisDocuments(String thesisId) =>
      '$thesis/$thesisId/documents';
  static String toDocumentPreview(
          {required String url, required String thesisId}) =>
      '$thesis/$thesisId/$documentPreview?url=$url';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static final router = GoRouter(
    debugLogDiagnostics: true,
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
            routes: [
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: RouteLocation.thesisCreate,
                name: 'thesis_create',
                // builder: (context, state) => const ThesisCreateScreen(),
                pageBuilder: (context, state) {
                  return RawDialogPage(
                    barrierDismissible: true,
                    barrierColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: const ThesisCreateScreen(),
                  );
                },
              ),
            ],
          ),
          // Thesis Routes
          GoRoute(
            path: RouteLocation.myThesis,
            name: 'my_thesis',
            builder: (context, state) => const MyThesisScreen(),
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
            builder: (context, state) {
              final status = state.extra as List<ThesisStatus>?;
              log(status.toString());
              return BrowseThesisScreen(
                status: status?.map((e) => e.name).toList(),
              );
            },
          ),
          GoRoute(
            path: RouteLocation.thesisDetail,
            name: 'thesis_detail',
            builder: (context, state) {
              var thesis = state.extra as Thesis?;
              if (thesis == null) {
                return const Center(
                  child: Text('Thesis not found'),
                );
              }
              return ThesisDetailScreen(thesis: thesis);
            },
            routes: [
              // Document Preview Route
              GoRoute(
                parentNavigatorKey: _rootNavigatorKey,
                path: RouteLocation.documentPreview,
                name: 'document_preview',
                pageBuilder: (context, state) {
                  final url = state.uri.queryParameters['url'];
                  if (url == null) {
                    return RawDialogPage(
                      barrierDismissible: true,
                      barrierColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      child: const Center(
                        child: Text('No URL provided'),
                      ),
                    );
                  }

                  return RawDialogPage(
                    barrierDismissible: true,
                    barrierColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: DocumentPreviewScreen(url: url),
                  );
                },
              ),
            ],
          ),     
          GoRoute(
            path: RouteLocation.topProgress,
            name: 'top_progress',
            builder: (context, state) => const TopProgressView(),
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
