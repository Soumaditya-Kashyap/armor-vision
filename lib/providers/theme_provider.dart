import 'package:flutter/material.dart';
import '../services/simple_database_service.dart';
import '../utils/armor_themes.dart';

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  final DatabaseService _databaseService = DatabaseService();
  ArmorThemeMode _currentThemeMode = ArmorThemeMode.system;
  bool _isInitialized = false;

  ArmorThemeMode get currentThemeMode => _currentThemeMode;
  bool get isInitialized => _isInitialized;

  ThemeData getTheme(Brightness platformBrightness) {
    return ArmorThemes.getTheme(_currentThemeMode, platformBrightness);
  }

  ThemeMode get themeMode {
    switch (_currentThemeMode) {
      case ArmorThemeMode.light:
        return ThemeMode.light;
      case ArmorThemeMode.dark:
        return ThemeMode.dark;
      case ArmorThemeMode.armor:
        return ThemeMode.dark; // Aurora theme uses dark mode base
      case ArmorThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final settings = await _databaseService.getAppSettings();
      _currentThemeMode = settings.effectiveThemeMode;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _currentThemeMode = ArmorThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ArmorThemeMode newTheme) async {
    if (_currentThemeMode == newTheme) return;

    try {
      // Update local state immediately for smooth transition
      _currentThemeMode = newTheme;
      notifyListeners();

      // Persist to database
      final settings = await _databaseService.getAppSettings();
      final updatedSettings = settings.copyWith(
        themeMode: newTheme,
        updatedAt: DateTime.now(),
      );

      await _databaseService.saveAppSettings(updatedSettings);
    } catch (e) {
      // Revert on error
      final settings = await _databaseService.getAppSettings();
      _currentThemeMode = settings.effectiveThemeMode;
      notifyListeners();
      rethrow;
    }
  }
}
