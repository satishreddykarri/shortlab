import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const _ink = Color(0xFF18233B);
  static const _brand = Color(0xFF4658E8);

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _brand,
      brightness: Brightness.light,
    ).copyWith(primary: _brand, onPrimary: Colors.white, surface: Colors.white),
    scaffoldBackgroundColor: const Color(0xFFF8F9FC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FC),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: _ink,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3E7F1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3E7F1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _brand, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD64545)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD64545), width: 1.6),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: _ink,
        fontSize: 56,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: -2.2,
      ),
      headlineMedium: TextStyle(
        color: _ink,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -1,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF5D667A),
        fontSize: 17,
        height: 1.65,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF5D667A),
        fontSize: 14,
        height: 1.5,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _ink,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
