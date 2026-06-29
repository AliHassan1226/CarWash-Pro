import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1566D2);
  static const Color primaryLight = Color(0xFFE8F0FE);

  // Secondary Colors
  static const Color secondaryColor = Color(0xFF34A853);
  static const Color secondaryLight = Color(0xFFE6F4EA);

  // Accent Colors
  static const Color accentColor = Color(0xFFEA4335);
  static const Color warningColor = Color(0xFFFBBC04);
  static const Color successColor = Color(0xFF34A853);

  // Neutral Colors
  static const Color darkGrey = Color(0xFF202124);
  static const Color mediumGrey = Color(0xFF5F6368);
  static const Color lightGrey = Color(0xFFF8F9FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Background Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFD32F2F);

  // Shadows
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x24000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowLarge = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: white,
        foregroundColor: darkGrey,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkGrey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkGrey,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: darkGrey,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkGrey,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGrey,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkGrey,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkGrey,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkGrey,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: mediumGrey,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: mediumGrey,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: mediumGrey,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: mediumGrey,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: lightGrey,
        selectedColor: primaryColor,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: darkGrey,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: lightGrey,
        thickness: 1,
        space: 16,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: accentColor,
        surface: Color(0xFF1E1E1E),
        background: Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: white,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFFB0B0B0),
        ),
      ),
    );
  }

  // Border Radius
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXLarge = 20;

  // Spacing
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;
}
