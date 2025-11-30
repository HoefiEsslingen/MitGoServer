// -----------------------------------------------------------------
// File: lib/theme/app_theme.dart
// Centralized theme definitions. Import this file and apply AppTheme.lightTheme
// (and optionally darkTheme) in your MaterialApp.

import 'package:flutter/material.dart';

class AppTheme {
// Primary color palette
  static const Color _hinterGrund = Colors.red;
  static const Color _textFarbe = Colors.black;
  static const Color _titelTextFarbe = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: _hinterGrund, 
    scaffoldBackgroundColor: _hinterGrund,
    appBarTheme: const AppBarTheme(
      backgroundColor: _hinterGrund, 
      foregroundColor: _titelTextFarbe,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _textFarbe,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
          color: _titelTextFarbe, fontSize: 48, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: _textFarbe, fontSize: 24),
      bodySmall: TextStyle(color: _textFarbe, fontSize: 14),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          backgroundColor: Colors.white, foregroundColor: _textFarbe),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Colors.white,
      errorStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(
      color: _titelTextFarbe,
      size: 32,
      ),
  );
}