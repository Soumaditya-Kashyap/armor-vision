import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/database_service.dart'; // Changed from simple_database_service.dart
import 'screens/splash_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize database with error handling for migration
  bool showOnboarding = false;
  try {
    final databaseService = DatabaseService();
    await databaseService.initialize();
    print('Database initialized successfully');

    // Check onboarding status BEFORE showing any screen
    final settings = await databaseService.getAppSettings();
    showOnboarding = !(settings.hasCompletedOnboarding ?? false);
  } catch (e) {
    print('Failed to initialize database: $e');
    // If database fails to initialize due to schema changes, we could potentially
    // clear it and reinitialize, but for now we'll let the app handle it gracefully
  }

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(
    ArmorApp(themeProvider: themeProvider, showOnboarding: showOnboarding),
  );
}

class ArmorApp extends StatefulWidget {
  final ThemeProvider themeProvider;
  final bool showOnboarding;

  const ArmorApp({
    super.key,
    required this.themeProvider,
    this.showOnboarding = false,
  });

  @override
  State<ArmorApp> createState() => _ArmorAppState();
}

class _ArmorAppState extends State<ArmorApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Armor - Secure Password Manager',
            theme: themeProvider.getTheme(Brightness.light),
            darkTheme: themeProvider.getTheme(Brightness.dark),
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: widget.showOnboarding
                ? const OnboardingScreen()
                : const SplashScreen(),
            routes: {'/settings': (context) => const SettingsScreen()},
          );
        },
      ),
    );
  }
}
