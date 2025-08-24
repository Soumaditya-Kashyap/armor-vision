import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/simple_database_service.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize database
  try {
    final databaseService = DatabaseService();
    await databaseService.initialize();
    print('Database initialized successfully');
  } catch (e) {
    print('Failed to initialize database: $e');
  }

  runApp(const ArmorApp());
}

class ArmorApp extends StatelessWidget {
  const ArmorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Armor - Secure Password Manager',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
