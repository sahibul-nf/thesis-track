import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  // static const primaryColor = Color(0xFF4669FA); // Blue
  static const primaryColor = Color(0xFF6B9BFF); // Soft Blue
  static const secondaryColor = Color(0xFFFF8F6B); // Orange
  static const backgroundColor = Color(0xFFFAFBFF); // Very Light Blue tint

  // Neutral Colors
  static const _neutralDark = Color(0xFF1F2937);
  static const _neutralMedium = Color(0xFF6B7280);
  static const _neutralLight = Color(0xFFE5E7EB);

  // Semantic Colors
  static const successColor = Color(0xFF50C793);
  static const warningColor = Color(0xFFFFB959);
  static const errorColor = Color.fromARGB(255, 248, 83, 61);
  static const infoColor = Color(0xFF4669FA);

  // Surface Colors
  static const _surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const _surfaceMedium =
      Color.fromARGB(255, 250, 251, 252); // Very Light Gray

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

  // Button's Variants
  static const _buttonLarge = 52.0;
  static const _buttonMedium = 48.0;
  static const _buttonSmall = 44.0;

  static var cardShadow = const BoxShadow(
    color: Color(0x00000014),
    blurRadius: 20,
    spreadRadius: 3,
    offset: Offset(0, 3),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: _surfaceMedium,
      surfaceContainer: _surfaceLight,
      background: backgroundColor,
      error: errorColor,
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
      backgroundColor: _surfaceMedium,
      elevation: 0,
      centerTitle: false,
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
        // backgroundColor: primaryColor,
        // foregroundColor: Colors.white,
        elevation: _buttonElevation,
        minimumSize: const Size(double.infinity, _buttonMedium),
        padding: const EdgeInsets.symmetric(
            horizontal: _spaceLG, vertical: _spaceMD),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(_buttonRadius),
        // ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        // backgroundColor: primaryColor,
        // foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, _buttonMedium),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(_buttonRadius),
        // ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        // foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        minimumSize: const Size(double.infinity, _buttonMedium),
        padding: const EdgeInsets.symmetric(
            horizontal: _spaceLG, vertical: _spaceMD),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(_buttonRadius),
        // ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceLight,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _spaceMD,
        vertical: _spaceMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        borderSide: const BorderSide(color: _neutralLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        borderSide: const BorderSide(color: _neutralLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: _neutralMedium, fontSize: 14),
      hintStyle: const TextStyle(
          color: _neutralMedium, fontSize: 14, fontWeight: FontWeight.w400),
      errorStyle: const TextStyle(color: errorColor, fontSize: 12),
      prefixIconColor: _neutralMedium,
      suffixIconColor: _neutralMedium,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        side: const BorderSide(color: _neutralLight),
        visualDensity: VisualDensity.comfortable,
        foregroundColor: _neutralMedium,
        backgroundColor: _surfaceLight,
        disabledIconColor: _neutralMedium,
        disabledForegroundColor: _neutralMedium,
        disabledBackgroundColor: _surfaceLight,
        iconColor: secondaryColor,
        selectedForegroundColor: secondaryColor,
        selectedBackgroundColor: secondaryColor.withOpacity(0.1),
      ),
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
      color: primaryColor,
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
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_modalRadius),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        surfaceTintColor: const WidgetStatePropertyAll(Colors.white),
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.3)),
        elevation: const WidgetStatePropertyAll(1),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
        ),
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      indicatorColor: Colors.transparent,
      tileHeight: 48,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: primaryColor,
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
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(color: _neutralDark),
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
        backgroundColor: primaryColor,
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
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
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
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_buttonRadius),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: _neutralMedium, fontSize: 14),
      hintStyle: const TextStyle(color: _neutralMedium, fontSize: 14),
      errorStyle: const TextStyle(color: errorColor, fontSize: 14),
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
      color: primaryColor,
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
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: _spaceMD,
        vertical: _spaceSM,
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: _neutralMedium,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: _neutralMedium,
      selectedLabelStyle: TextStyle(color: primaryColor),
      unselectedLabelStyle: TextStyle(color: _neutralMedium),
    ),
    dialogBackgroundColor: Colors.white,
  );

  // Status color getters
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proposed':
        return infoColor;
      case 'in progress':
        return warningColor;
      case 'completed':
        return successColor;
      case 'rejected':
        return errorColor;
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

  // Button's Variants
  static double get buttonLarge => _buttonLarge;
  static double get buttonMedium => _buttonMedium;
  static double get buttonSmall => _buttonSmall;
}
