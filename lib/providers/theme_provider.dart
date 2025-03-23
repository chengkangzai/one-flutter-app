// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Key for storing theme preference
  static const String _darkModeKey = 'dark_mode_enabled';

  // Default value for dark mode
  static const bool _defaultDarkMode = false;

  // Current theme mode
  bool _isDarkMode = _defaultDarkMode;

  // Constructor
  ThemeProvider() {
    _loadThemePreference();
  }

  // Getter for dark mode state
  bool get isDarkMode => _isDarkMode;

  // Get theme mode as ThemeMode enum
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Load theme from shared preferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? _defaultDarkMode;
    notifyListeners();
  }

  // Toggle theme mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);

    notifyListeners();
  }

  // Set theme mode explicitly
  Future<void> setDarkMode(bool darkMode) async {
    if (_isDarkMode != darkMode) {
      _isDarkMode = darkMode;

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, _isDarkMode);

      notifyListeners();
    }
  }

  // Get color scheme for current theme
  ColorScheme get colorScheme =>
      _isDarkMode ? _darkColorScheme : _lightColorScheme;

  // Light theme color scheme
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.blue,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDCE4FF),
    onPrimaryContainer: Color(0xFF001847),
    secondary: Color(0xFF1976D2),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFDBE2FF),
    onSecondaryContainer: Color(0xFF001847),
    tertiary: Color(0xFF735CA7),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFEADDFF),
    onTertiaryContainer: Color(0xFF2B1658),
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    background: Colors.white,
    onBackground: Color(0xFF1A1C1E),
    surface: Colors.white,
    onSurface: Color(0xFF1A1C1E),
    surfaceVariant: Color(0xFFE1E2EC),
    onSurfaceVariant: Color(0xFF44474F),
    outline: Color(0xFF74777F),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFF2F3033),
    onInverseSurface: Color(0xFFF1F0F4),
    inversePrimary: Color(0xFFB0C6FF),
    surfaceTint: Colors.transparent,
  );

  // Dark theme color scheme
  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF99CAFF),
    onPrimary: Color(0xFF002F67),
    primaryContainer: Color(0xFF00458E),
    onPrimaryContainer: Color(0xFFD4E3FF),
    secondary: Color(0xFF90CBFF),
    onSecondary: Color(0xFF00497B),
    secondaryContainer: Color(0xFF0068AD),
    onSecondaryContainer: Color(0xFFCFE5FF),
    tertiary: Color(0xFFCEBDFF),
    onTertiary: Color(0xFF41296E),
    tertiaryContainer: Color(0xFF594185),
    onTertiaryContainer: Color(0xFFEADDFF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFB4AB),
    background: Color(0xFF1A1C1E),
    onBackground: Color(0xFFE2E2E6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE2E2E6),
    surfaceVariant: Color(0xFF44474F),
    onSurfaceVariant: Color(0xFFC5C6D0),
    outline: Color(0xFF8E9099),
    shadow: Color(0xFF000000),
    inverseSurface: Color(0xFFE2E2E6),
    onInverseSurface: Color(0xFF1A1C1E),
    inversePrimary: Color(0xFF0062B4),
    surfaceTint: Colors.transparent,
  );
}
