import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:thesis_track_flutter_app/app/bindings/initial_binding.dart';
import 'package:thesis_track_flutter_app/app/core/storage_service.dart';
import 'package:thesis_track_flutter_app/app/routes/app_routes.dart';
import 'package:thesis_track_flutter_app/app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This is required for the web version of the app to work properly
  usePathUrlStrategy();
  
  await dotenv.load(fileName: ".env");
  await StorageService.init();

  // Initialize bindings
  InitialBinding().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return shadcn.ShadcnApp.router(
      title: 'Thesis Track',
      // theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      theme: shadcn.ThemeData(
        colorScheme: shadcn.ColorSchemes.lightBlue(),
        surfaceOpacity: 0.9,
        radius: 0.7,
      ),
      materialTheme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      // routeInformationParser: AppRoutes.router.routeInformationParser,
      // routeInformationProvider: AppRoutes.router.routeInformationProvider,
      // routerDelegate: AppRoutes.router.routerDelegate,
    );
  }
}
