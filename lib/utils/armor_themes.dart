import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:google_fonts/google_fonts.dart';

part 'armor_themes.g.dart';

@HiveType(typeId: 9)
enum ArmorThemeMode {
  @HiveField(0)
  light,

  @HiveField(1)
  dark,

  @HiveField(2)
  system,

  @HiveField(3)
  armor,
}

class ArmorThemes {
  static ThemeData getTheme(
    ArmorThemeMode mode,
    Brightness platformBrightness,
  ) {
    switch (mode) {
      case ArmorThemeMode.light:
        return _lightTheme;
      case ArmorThemeMode.dark:
        return _darkTheme;
      case ArmorThemeMode.armor:
        return _armorTheme;
      case ArmorThemeMode.system:
        return platformBrightness == Brightness.dark ? _darkTheme : _lightTheme;
    }
  }

  // Light Theme
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.bricolageGrotesqueTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  // Dark Theme
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1976D2),
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.bricolageGrotesqueTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
  );

  // Special Armor Aurora Theme - Enhanced with gradients and special effects
  static final ThemeData _armorTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.bricolageGrotesqueTextTheme(),
    colorScheme: const ColorScheme.dark(
      // Deep cosmic background with aurora hints
      surface: Color(0xFF0B0B1F), // Deeper space blue
      onSurface: Color(0xFFE8F4FD), // Slightly blue-tinted white
      // Aurora primary cyan with glow
      primary: Color(0xFF00FFFF), // Pure cyan aurora
      onPrimary: Color(0xFF001A1A),

      // Aurora secondary magenta/purple
      secondary: Color(0xFFFF00FF), // Pure magenta aurora
      onSecondary: Color(0xFF1A001A),

      // Aurora tertiary green
      tertiary: Color(0xFF00FF88), // Aurora green
      onTertiary: Color(0xFF001A10),

      // Container colors with aurora glow effects
      primaryContainer: Color(0xFF003333), // Dark cyan container
      onPrimaryContainer: Color(0xFF80FFFF), // Light cyan text

      secondaryContainer: Color(0xFF330033), // Dark magenta container
      onSecondaryContainer: Color(0xFFFF80FF), // Light magenta text

      tertiaryContainer: Color(0xFF003320), // Dark green container
      onTertiaryContainer: Color(0xFF80FFAA), // Light green text
      // Error colors with aurora styling
      error: Color(0xFFFF4081), // Aurora pink error
      onError: Color(0xFF1A0010),
      errorContainer: Color(0xFF4A0020),
      onErrorContainer: Color(0xFFFFB3CC),

      // Background with starfield effect
      background: Color(0xFF060612), // Almost black with blue hint
      onBackground: Color(0xFFE8F4FD),

      // Surface variants with cosmic aurora
      surfaceVariant: Color(0xFF1A1A3A), // Deep space purple
      onSurfaceVariant: Color(0xFFCCDDFF), // Light cosmic blue
      // Outline colors with glow
      outline: Color(0xFF4D79A4), // Aurora blue outline
      outlineVariant: Color(0xFF2A3F5F), // Darker aurora outline
      // Inverse colors
      inverseSurface: Color(0xFFE8F4FD),
      onInverseSurface: Color(0xFF121218),
      inversePrimary: Color(0xFF006666),

      // Shadow and scrim with aurora effects
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),

      // Surface tints with aurora glow
      surfaceTint: Color(0xFF00FFFF),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: Color(0xFF0B0B1F),
      foregroundColor: Color(0xFF00FFFF),
      shadowColor: Color(0xFF00FFFF),
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shadowColor: const Color(0xFF00FFFF).withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: const Color(0xFF00FFFF).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      color: const Color(0xFF1A1A3A),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FFFF),
        foregroundColor: const Color(0xFF001A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        elevation: 8,
        shadowColor: const Color(0xFF00FFFF).withOpacity(0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: const Color(0xFF00FFFF).withOpacity(0.5),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: const Color(0xFF4D79A4).withOpacity(0.6),
          width: 1.5,
        ),
      ),
      fillColor: const Color(0xFF1A1A3A),
      filled: true,
      labelStyle: const TextStyle(color: Color(0xFF80FFFF)),
      hintStyle: TextStyle(color: const Color(0xFFCCDDFF).withOpacity(0.7)),
    ),
    dividerTheme: DividerThemeData(
      color: const Color(0xFF00FFFF).withOpacity(0.3),
      thickness: 1.5,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFF00FFFF),
      linearTrackColor: Color(0xFF003333),
      circularTrackColor: Color(0xFF003333),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xFF00FFFF);
        }
        return const Color(0xFF4D79A4);
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const Color(0xFF003333);
        }
        return const Color(0xFF2A3F5F);
      }),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: Color(0xFF00FFFF),
      inactiveTrackColor: Color(0xFF4D79A4),
      thumbColor: Color(0xFF00FFFF),
      overlayColor: Color(0x3300FFFF),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00FFFF),
      foregroundColor: Color(0xFF001A1A),
      elevation: 8,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A3A),
      selectedItemColor: Color(0xFF00FFFF),
      unselectedItemColor: Color(0xFF4D79A4),
      elevation: 8,
    ),
  );

  // Theme mode display helpers
  static String getThemeDisplayName(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return 'Light';
      case ArmorThemeMode.dark:
        return 'Dark';
      case ArmorThemeMode.system:
        return 'System';
      case ArmorThemeMode.armor:
        return 'Armor Aurora';
    }
  }

  static String getThemeDescription(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return 'Clean and bright theme for daytime use';
      case ArmorThemeMode.dark:
        return 'Easy on the eyes for nighttime use';
      case ArmorThemeMode.system:
        return 'Follows your device settings';
      case ArmorThemeMode.armor:
        return 'Vibrant aurora with cosmic starry effects';
    }
  }

  static IconData getThemeIcon(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return Icons.light_mode;
      case ArmorThemeMode.dark:
        return Icons.dark_mode;
      case ArmorThemeMode.system:
        return Icons.settings_system_daydream;
      case ArmorThemeMode.armor:
        return Icons.auto_awesome;
    }
  }

  // Get theme preview colors for settings UI
  static Color getThemePreviewColor(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return const Color(0xFF1976D2); // Blue
      case ArmorThemeMode.dark:
        return const Color(0xFF90CAF9); // Light blue for dark theme
      case ArmorThemeMode.system:
        return const Color(0xFF757575); // Darker gray for better contrast
      case ArmorThemeMode.armor:
        return const Color(0xFF00FFFF); // Pure cyan for Aurora
    }
  }

  static Color getThemeBackgroundColor(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return const Color(0xFFFAFAFA); // Very light gray for better contrast
      case ArmorThemeMode.dark:
        return const Color(0xFF121212);
      case ArmorThemeMode.system:
        return const Color(0xFF2C2C2E); // Dark gray for better appearance
      case ArmorThemeMode.armor:
        return const Color(0xFF0B0B1F); // Deep cosmic background
    }
  }
}
