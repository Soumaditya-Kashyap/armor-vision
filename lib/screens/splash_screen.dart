import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';
import '../utils/constants.dart';
import 'auth/auth_screen.dart';
import 'home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusText = 'Initializing Armor...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize core services step by step
      await _initializeWithStatus('Setting up encryption...', () async {
        await EncryptionService().initialize();
        await Future.delayed(const Duration(milliseconds: 500));
      });

      await _initializeWithStatus('Preparing secure database...', () async {
        await DatabaseService().initialize();
        await Future.delayed(const Duration(milliseconds: 500));
      });

      await _initializeWithStatus('Configuring authentication...', () async {
        await AuthService().initialize();
        await Future.delayed(const Duration(milliseconds: 500));
      });

      await _initializeWithStatus('Finalizing setup...', () async {
        await Future.delayed(const Duration(milliseconds: 800));
      });

      // Wait for animation to complete
      await _animationController.forward();

      // Navigate to appropriate screen
      await _navigateToNextScreen();
    } catch (e) {
      setState(() {
        _hasError = true;
        _statusText = 'Failed to initialize: ${e.toString()}';
      });
    }
  }

  Future<void> _initializeWithStatus(
      String status, Future<void> Function() task) async {
    setState(() {
      _statusText = status;
    });
    await task();
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Check if user needs authentication
    final authService = AuthService();
    final needsAuth = authService.requiresAuthentication();

    // Small delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return needsAuth ? const AuthScreen() : const HomeScreen();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // App Logo/Icon
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.security_rounded,
                                  size: 60,
                                  color: colorScheme.onPrimary,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // App Name
                              Text(
                                AppConstants.appName,
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // App Description
                              Text(
                                AppConstants.appDescription,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Status Section
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!_hasError) ...[
                              // Loading Indicator
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Status Text
                              Text(
                                _statusText,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.8),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              // Error Icon
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: colorScheme.error,
                              ),

                              const SizedBox(height: 16),

                              // Error Text
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  _statusText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Retry Button
                              FilledButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _hasError = false;
                                    _statusText = 'Retrying...';
                                  });
                                  _initializeApp();
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Version ${AppConstants.appVersion}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_rounded,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Secure • Offline • Private',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
