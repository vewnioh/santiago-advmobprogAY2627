// Import Flutter material library for theme data configurations
import 'package:flutter/material.dart';

// Provider state management class handling global light and dark theme mode switching
class ThemeProvider with ChangeNotifier {
  // Private boolean flag tracking whether dark mode is currently enabled
  bool _isDark = false;

  // Public getter exposing current dark mode status to listening widgets
  bool get isDark => _isDark;

  // Getter returning application light theme data configuration
  ThemeData get lightTheme => ThemeData.light();

  // Getter returning application dark theme data configuration
  ThemeData get darkTheme => ThemeData.dark();

  // Method to toggle theme mode state and notify listener widgets to rebuild
  void toggleTheme() {
    // Inverts the private boolean flag between light and dark mode
    _isDark = !_isDark;

    // Triggers widget rebuilds for all subscribers listening to this provider
    notifyListeners();
  }
}
