import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const _primaryColor = Color(0xFF4CAF50); // Soft Green
  static const _secondaryColor = Color(0xFF81C784); // Light Green
  static const _backgroundColor = Color(0xFFF5F9F6); // Very Light Green tint

  // Neutral Colors
  static const _neutralDark = Color(0xFF1F2937);
  static const _neutralMedium = Color(0xFF6B7280);
  static const _neutralLight = Color(0xFFE5E7EB);

  // Semantic Colors
  static const _successColor = Color(0xFF22C55E);
  static const _warningColor = Color(0xFFFACC15);
  static const _errorColor = Color(0xFFEF4444);
  static const _infoColor = Color(0xFF3B82F6);

  // Elevation values
  static const _cardElevation = 2.0;
  static const _modalElevation = 3.0;
  static const _buttonElevation = 1.0;

  // Border Radius values
  static const _buttonRadius = 8.0;
  static const _cardRadius = 12.0;
  static const _modalRadius = 16.0;
  static const _chipRadius = 20.0;

  // Spacing values
  static const _spaceXS = 4.0;
  static const _spaceSM = 8.0;
  static const _spaceMD = 16.0;
  static const _spaceLG = 24.0;
  static const _spaceXL = 32.0;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: _backgroundColor,
      error: _errorColor,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: const TextStyle(color: _neutralDark),
      displayMedium: const TextStyle(color: _neutralDark),
      displaySmall: const TextStyle(color: _neutralDark),
      headlineLarge: const TextStyle(color: _neutralDark),
      headlineMedium: const TextStyle(color: _neutralDark),
      headlineSmall: const TextStyle(color: _neutralDark),
      titleLarge: const TextStyle(color: _neutralDark),
      titleMedium: const TextStyle(color: _neutralDark),
      titleSmall: const TextStyle(color: _neutralDark),
      bodyLarge: const TextStyle(color: _neutralDark),
      bodyMedium: const TextStyle(color: _neutralMedium),
      bodySmall: const TextStyle(color: _neutralMedium),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _primaryColor),
      titleTextStyle: TextStyle(
        color: _neutralDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      elevation: _cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      color: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: _buttonElevation,
        padding: const EdgeInsets.symmetric(
            horizontal: _spaceLG, vertical: _spaceMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryColor,
        side: const BorderSide(color: _primaryColor),
        padding: const EdgeInsets.symmetric(
            horizontal: _spaceLG, vertical: _spaceMD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _spaceMD,
        vertical: _spaceMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: _neutralLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: _neutralLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: _errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: _neutralMedium),
      hintStyle: const TextStyle(color: _neutralMedium),
      errorStyle: const TextStyle(color: _errorColor),
      prefixIconColor: _neutralMedium,
      suffixIconColor: _neutralMedium,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_chipRadius),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: _spaceMD,
        vertical: _spaceSM,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _neutralDark.withOpacity(0.9),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: _neutralLight,
      thickness: 1,
      space: _spaceMD,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _primaryColor,
      circularTrackColor: _neutralLight,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: _modalElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_modalRadius),
        ),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      elevation: _modalElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_modalRadius),
      ),
    ),
  );

  // Status color getters
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proposed':
        return _infoColor;
      case 'in progress':
        return _warningColor;
      case 'completed':
        return _successColor;
      case 'rejected':
        return _errorColor;
      default:
        return _neutralMedium;
    }
  }

  // Spacing getters
  static double get spaceXS => _spaceXS;
  static double get spaceSM => _spaceSM;
  static double get spaceMD => _spaceMD;
  static double get spaceLG => _spaceLG;
  static double get spaceXL => _spaceXL;

  // Border radius getters
  static double get buttonRadius => _buttonRadius;
  static double get cardRadius => _cardRadius;
  static double get modalRadius => _modalRadius;
  static double get chipRadius => _chipRadius;
}
