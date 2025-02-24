import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thesis_track_flutter_app/app/core/route_guard.dart';
import 'package:thesis_track_flutter_app/app/modules/auth/screens/screens.dart';
import 'package:thesis_track_flutter_app/app/modules/home/screens/screens.dart';
import 'package:thesis_track_flutter_app/app/modules/progress/screens/screens.dart';
import 'package:thesis_track_flutter_app/app/modules/thesis/screens/screens.dart';

class AppRoutes {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: RouteGuard.handle,
    errorBuilder: (context, state) => const RouteErrorScreen(
      message: 'The requested page could not be found.',
    ),
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => RegisterScreen(),
      ),

      // Main Routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Thesis Routes
      GoRoute(
        path: '/thesis/create',
        name: 'thesis_create',
        builder: (context, state) => const ThesisCreateScreen(),
      ),
      GoRoute(
        path: '/thesis/:id',
        name: 'thesis_detail',
        builder: (context, state) => ThesisDetailScreen(
          thesisId: state.pathParameters['id']!,
        ),
      ),

      // Progress Routes
      GoRoute(
        path: '/progress/thesis/:thesisId',
        name: 'progress_list',
        builder: (context, state) => ProgressListScreen(
          thesisId: state.pathParameters['thesisId']!,
        ),
      ),
      GoRoute(
        path: '/progress/thesis/:thesisId/create',
        name: 'progress_create',
        builder: (context, state) => ProgressCreateScreen(
          thesisId: state.pathParameters['thesisId']!,
        ),
      ),
      GoRoute(
        path: '/progress/:progressId/detail',
        name: 'progress_detail',
        builder: (context, state) => ProgressDetailScreen(
          progressId: state.pathParameters['progressId']!,
        ),
      ),

      // Document Routes
      GoRoute(
        path: '/thesis/:thesisId/documents',
        name: 'thesis_documents',
        builder: (context, state) => ThesisDocumentsScreen(
          thesisId: state.pathParameters['thesisId']!,
        ),
      ),
    ],
  );
}
