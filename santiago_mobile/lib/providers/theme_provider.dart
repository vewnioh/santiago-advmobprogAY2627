// Import Flutter material library for theme data configurations
import 'package:flutter/material.dart';

// Provider state management class handling global light and dark theme mode switching with a uniform green design system
class ThemeProvider with ChangeNotifier {
  // Private boolean flag tracking whether dark mode is currently enabled
  bool _isDark = false;

  // Public getter exposing current dark mode status to listening widgets
  bool get isDark => _isDark;

  // Primary green theme color tokens
  static const Color primaryGreen = Color(0xFF2E7D32); // Rich Forest Green
  static const Color lightGreen = Color(0xFF4CAF50);   // Vibrant Emerald Green
  static const Color accentGreen = Color(0xFF81C784);  // Accent Soft Green

  // Getter returning application light theme data configuration with uniform green primary styling
  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: lightGreen,
          tertiary: accentGreen,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
        ),
      );

  // Getter returning application dark theme data configuration with uniform green accents
  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: lightGreen,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: lightGreen,
          secondary: accentGreen,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightGreen,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: lightGreen,
          foregroundColor: Colors.black,
        ),
      );

  // Method to toggle theme mode state and notify listener widgets to rebuild
  void toggleTheme() {
    // Inverts the private boolean flag between light and dark mode
    _isDark = !_isDark;

    // Triggers widget rebuilds for all subscribers listening to this provider
    notifyListeners();
  }
}
