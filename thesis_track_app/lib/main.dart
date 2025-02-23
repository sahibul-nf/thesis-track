import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:thesis_track_app/core/routes/app_routes.dart';
import 'package:thesis_track_app/core/theme/app_theme.dart';
import 'package:thesis_track_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:thesis_track_app/features/thesis/presentation/controllers/thesis_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialize controllers
  Get.put(AuthController());
  Get.put(ThesisController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Thesis Track',
      theme: AppTheme.lightTheme,
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
