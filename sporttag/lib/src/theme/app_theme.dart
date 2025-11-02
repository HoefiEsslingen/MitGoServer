// -----------------------------------------------------------------
// File: lib/theme/app_theme.dart
// Centralized theme definitions. Import this file and apply AppTheme.lightTheme
// (and optionally darkTheme) in your MaterialApp.

import 'package:flutter/material.dart';

class AppTheme {
// Primary color palette
  static const MaterialColor _primarySwatch = Colors.red;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: _primarySwatch, //const Color.fromARGB(255, 241, 79, 15),
    scaffoldBackgroundColor: _primarySwatch, //const Color.fromARGB(255, 246, 65, 10),
    appBarTheme: const AppBarTheme(
      backgroundColor: _primarySwatch, //const Color.fromARGB(255, 246, 65, 10),
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
      ),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(
          color: Colors.white, fontSize: 48, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: _primarySwatch, fontSize: 24),
      bodySmall: TextStyle(color: _primarySwatch, fontSize: 14),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          backgroundColor: Colors.white, foregroundColor: Colors.green),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Colors.white,
      errorStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
      size: 32,
      ),
  );

/******* 
    brightness: Brightness.light,
    primarySwatch: _primarySwatch,
    primaryColor: _primarySwatch,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D47A1), // deep blue
      elevation: 2,
      centerTitle: true,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          elevation: 2,
          padding:
              const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: _primarySwatch,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B3D91),
      elevation: 2,
      centerTitle: true,
      foregroundColor: Colors.white,
    ),
  );
*******/
}
