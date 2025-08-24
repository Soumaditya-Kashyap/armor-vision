import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:math';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _authConfigKey = 'auth_config';
  static const String _sessionTokenKey = 'session_token';
  static const String _lastAuthKey = 'last_auth_time';

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Session management
  String? _currentSessionToken;
  DateTime? _lastSuccessfulAuth;
  bool _isAuthenticated = false;
  int _sessionTimeoutMinutes = 5;

  // Security tracking
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 5;
  DateTime? _lockoutUntil;

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Initialize authentication service
  Future<void> initialize() async {
    try {
      await _loadAuthConfig();
      await _validateSession();
    } catch (e) {
      print('Auth service initialization warning: $e');
    }
  }

  /// Check if biometric authentication is available
  Future<BiometricCapability> getBiometricCapability() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        return BiometricCapability.notAvailable;
      }

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return BiometricCapability.notEnrolled;
      }

      // Determine the strongest available biometric
      if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricCapability.faceId;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricCapability.fingerprint;
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return BiometricCapability.iris;
      } else {
        return BiometricCapability.other;
      }
    } catch (e) {
      return BiometricCapability.error;
    }
  }

  /// Authenticate user with biometrics or device credentials
  Future<AuthResult> authenticate({
    String? reason,
    bool allowDeviceCredentials = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Check if locked out
      if (_isLockedOut()) {
        return AuthResult.lockedOut(_getRemainingLockoutTime());
      }

      final String authReason =
          reason ?? 'Please authenticate to access your secure vault';

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: authReason,
        options: AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: stickyAuth,
          biometricOnly: !allowDeviceCredentials,
        ),
      );

      if (didAuthenticate) {
        await _handleSuccessfulAuth();
        return AuthResult.success();
      } else {
        _handleFailedAuth();
        return AuthResult.userCancelled();
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      _handleFailedAuth();
      return AuthResult.error('Authentication failed: $e');
    }
  }

  /// Quick authentication for already authenticated sessions
  Future<AuthResult> quickAuth() async {
    if (_isAuthenticated && _isSessionValid()) {
      return AuthResult.success();
    }

    return authenticate(
      reason: 'Quick authentication required',
      allowDeviceCredentials: true,
      stickyAuth: false,
    );
  }

  /// Authenticate with app-specific PIN (fallback)
  Future<AuthResult> authenticateWithPin(String pin) async {
    try {
      if (_isLockedOut()) {
        return AuthResult.lockedOut(_getRemainingLockoutTime());
      }

      final storedPinHash = await _secureStorage.read(key: 'app_pin_hash');
      if (storedPinHash == null) {
        return AuthResult.error('No PIN configured');
      }

      final pinHash = _hashPin(pin);
      if (pinHash == storedPinHash) {
        await _handleSuccessfulAuth();
        return AuthResult.success();
      } else {
        _handleFailedAuth();
        return AuthResult.wrongCredentials();
      }
    } catch (e) {
      return AuthResult.error('PIN authentication failed: $e');
    }
  }

  /// Set up app-specific PIN
  Future<bool> setupPin(String pin) async {
    try {
      if (pin.length < 4) {
        return false; // PIN too short
      }

      final pinHash = _hashPin(pin);
      await _secureStorage.write(key: 'app_pin_hash', value: pinHash);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if user needs to re-authenticate
  bool requiresAuthentication() {
    if (!_isAuthenticated) return true;
    if (_isLockedOut()) return true;
    if (!_isSessionValid()) return true;
    return false;
  }

  /// Extend current session
  Future<void> extendSession({int? additionalMinutes}) async {
    if (_isAuthenticated) {
      _lastSuccessfulAuth = DateTime.now();
      await _saveAuthConfig();
    }
  }

  /// Logout and clear session
  Future<void> logout() async {
    _isAuthenticated = false;
    _currentSessionToken = null;
    _lastSuccessfulAuth = null;
    await _secureStorage.delete(key: _sessionTokenKey);
    await _secureStorage.delete(key: _lastAuthKey);
  }

  /// Configure session timeout
  Future<void> setSessionTimeout(int minutes) async {
    _sessionTimeoutMinutes = minutes;
    await _saveAuthConfig();
  }

  /// Get security metrics
  SecurityMetrics getSecurityMetrics() {
    return SecurityMetrics(
      isAuthenticated: _isAuthenticated,
      failedAttempts: _failedAttempts,
      isLockedOut: _isLockedOut(),
      lockoutUntil: _lockoutUntil,
      sessionTimeoutMinutes: _sessionTimeoutMinutes,
      lastAuthTime: _lastSuccessfulAuth,
      sessionValid: _isSessionValid(),
    );
  }

  /// Handle successful authentication
  Future<void> _handleSuccessfulAuth() async {
    _isAuthenticated = true;
    _failedAttempts = 0;
    _lockoutUntil = null;
    _lastSuccessfulAuth = DateTime.now();
    _currentSessionToken = _generateSessionToken();

    await _saveAuthConfig();
    await _secureStorage.write(
        key: _sessionTokenKey, value: _currentSessionToken!);
    await _secureStorage.write(
      key: _lastAuthKey,
      value: _lastSuccessfulAuth!.millisecondsSinceEpoch.toString(),
    );
  }

  /// Handle failed authentication
  void _handleFailedAuth() {
    _failedAttempts++;
    if (_failedAttempts >= _maxFailedAttempts) {
      // Progressive lockout: 1min, 5min, 15min, 30min, 1hr, 2hr, etc.
      final lockoutMinutes = _calculateLockoutDuration();
      _lockoutUntil = DateTime.now().add(Duration(minutes: lockoutMinutes));
    }
  }

  /// Calculate progressive lockout duration
  int _calculateLockoutDuration() {
    final excessAttempts = _failedAttempts - _maxFailedAttempts + 1;
    switch (excessAttempts) {
      case 1:
        return 1; // 1 minute
      case 2:
        return 5; // 5 minutes
      case 3:
        return 15; // 15 minutes
      case 4:
        return 30; // 30 minutes
      case 5:
        return 60; // 1 hour
      default:
        return 120; // 2 hours (max)
    }
  }

  /// Check if currently locked out
  bool _isLockedOut() {
    if (_lockoutUntil == null) return false;

    if (DateTime.now().isBefore(_lockoutUntil!)) {
      return true;
    }

    // Lockout expired
    _lockoutUntil = null;
    _failedAttempts = 0;
    return false;
  }

  /// Get remaining lockout time
  Duration _getRemainingLockoutTime() {
    if (_lockoutUntil == null) return Duration.zero;
    final remaining = _lockoutUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Validate current session
  Future<void> _validateSession() async {
    try {
      final sessionToken = await _secureStorage.read(key: _sessionTokenKey);
      final lastAuthString = await _secureStorage.read(key: _lastAuthKey);

      if (sessionToken != null && lastAuthString != null) {
        _currentSessionToken = sessionToken;
        _lastSuccessfulAuth =
            DateTime.fromMillisecondsSinceEpoch(int.parse(lastAuthString));

        if (_isSessionValid()) {
          _isAuthenticated = true;
        } else {
          await logout();
        }
      }
    } catch (e) {
      await logout();
    }
  }

  /// Check if session is still valid
  bool _isSessionValid() {
    if (_lastSuccessfulAuth == null) return false;

    final sessionDuration = DateTime.now().difference(_lastSuccessfulAuth!);
    return sessionDuration.inMinutes < _sessionTimeoutMinutes;
  }

  /// Generate secure session token
  String _generateSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Hash PIN with salt
  String _hashPin(String pin) {
    // In production, use proper password hashing like bcrypt or Argon2
    // This is a simplified version for demo
    final salt = 'armor_pin_salt_2024';
    final combined = '$pin$salt';
    return base64.encode(combined.codeUnits);
  }

  /// Load authentication configuration
  Future<void> _loadAuthConfig() async {
    try {
      final configString = await _secureStorage.read(key: _authConfigKey);
      if (configString != null) {
        final config = jsonDecode(configString) as Map<String, dynamic>;
        _sessionTimeoutMinutes = config['sessionTimeout'] ?? 5;
        _failedAttempts = config['failedAttempts'] ?? 0;

        if (config['lockoutUntil'] != null) {
          _lockoutUntil = DateTime.fromMillisecondsSinceEpoch(
              config['lockoutUntil'] as int);
        }
      }
    } catch (e) {
      // Use defaults if config is corrupted
      _sessionTimeoutMinutes = 5;
      _failedAttempts = 0;
      _lockoutUntil = null;
    }
  }

  /// Save authentication configuration
  Future<void> _saveAuthConfig() async {
    try {
      final config = {
        'sessionTimeout': _sessionTimeoutMinutes,
        'failedAttempts': _failedAttempts,
        'lockoutUntil': _lockoutUntil?.millisecondsSinceEpoch,
      };

      await _secureStorage.write(
        key: _authConfigKey,
        value: jsonEncode(config),
      );
    } catch (e) {
      // Silent fail for config save
    }
  }

  /// Handle platform-specific authentication exceptions
  AuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return AuthResult.notAvailable();
      case 'NotEnrolled':
        return AuthResult.notEnrolled();
      case 'PasscodeNotSet':
        return AuthResult.passcodeNotSet();
      case 'UserCancel':
        return AuthResult.userCancelled();
      case 'UserFallback':
        return AuthResult.userFallback();
      case 'BiometricOnlyNotSupported':
        return AuthResult.biometricOnlyNotSupported();
      case 'DeviceNotSupported':
        return AuthResult.deviceNotSupported();
      case 'ApplicationLock':
        return AuthResult.applicationLock();
      case 'InvalidContext':
        return AuthResult.invalidContext();
      case 'NotInteractive':
        return AuthResult.notInteractive();
      default:
        _handleFailedAuth();
        // Check for FragmentActivity error specifically
        if (e.message?.contains('FragmentActivity') == true) {
          return AuthResult.error(
              'Biometric authentication is temporarily unavailable. Please use device passcode.');
        }
        return AuthResult.error('Platform error: ${e.message}');
    }
  }

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  int get failedAttempts => _failedAttempts;
  int get sessionTimeoutMinutes => _sessionTimeoutMinutes;
  DateTime? get lastAuthTime => _lastSuccessfulAuth;
  bool get isLockedOut => _isLockedOut();
  Duration get remainingLockoutTime => _getRemainingLockoutTime();
}

// Supporting classes and enums
enum BiometricCapability {
  notAvailable,
  notEnrolled,
  fingerprint,
  faceId,
  iris,
  other,
  error,
}

class AuthResult {
  final bool success;
  final AuthError? error;
  final String? message;
  final Duration? lockoutDuration;

  AuthResult._(this.success, this.error, this.message, this.lockoutDuration);

  factory AuthResult.success() => AuthResult._(true, null, null, null);
  factory AuthResult.userCancelled() => AuthResult._(
      false, AuthError.userCancelled, 'User cancelled authentication', null);
  factory AuthResult.wrongCredentials() => AuthResult._(
      false, AuthError.wrongCredentials, 'Wrong credentials provided', null);
  factory AuthResult.lockedOut(Duration duration) => AuthResult._(
      false, AuthError.lockedOut, 'Account temporarily locked', duration);
  factory AuthResult.notAvailable() => AuthResult._(false,
      AuthError.notAvailable, 'Biometric authentication not available', null);
  factory AuthResult.notEnrolled() => AuthResult._(
      false, AuthError.notEnrolled, 'No biometrics enrolled', null);
  factory AuthResult.passcodeNotSet() => AuthResult._(
      false, AuthError.passcodeNotSet, 'Device passcode not set', null);
  factory AuthResult.userFallback() => AuthResult._(
      false, AuthError.userFallback, 'User chose fallback method', null);
  factory AuthResult.biometricOnlyNotSupported() => AuthResult._(
      false,
      AuthError.biometricOnlyNotSupported,
      'Biometric-only mode not supported',
      null);
  factory AuthResult.deviceNotSupported() => AuthResult._(
      false, AuthError.deviceNotSupported, 'Device not supported', null);
  factory AuthResult.applicationLock() => AuthResult._(
      false, AuthError.applicationLock, 'Application is locked', null);
  factory AuthResult.invalidContext() => AuthResult._(
      false, AuthError.invalidContext, 'Invalid authentication context', null);
  factory AuthResult.notInteractive() => AuthResult._(
      false, AuthError.notInteractive, 'Authentication not interactive', null);
  factory AuthResult.error(String message) =>
      AuthResult._(false, AuthError.unknown, message, null);
}

enum AuthError {
  userCancelled,
  wrongCredentials,
  lockedOut,
  notAvailable,
  notEnrolled,
  passcodeNotSet,
  userFallback,
  biometricOnlyNotSupported,
  deviceNotSupported,
  applicationLock,
  invalidContext,
  notInteractive,
  platformError,
  unknown,
}

class SecurityMetrics {
  final bool isAuthenticated;
  final int failedAttempts;
  final bool isLockedOut;
  final DateTime? lockoutUntil;
  final int sessionTimeoutMinutes;
  final DateTime? lastAuthTime;
  final bool sessionValid;

  SecurityMetrics({
    required this.isAuthenticated,
    required this.failedAttempts,
    required this.isLockedOut,
    this.lockoutUntil,
    required this.sessionTimeoutMinutes,
    this.lastAuthTime,
    required this.sessionValid,
  });
}

// Extensions for better display
extension BiometricCapabilityExtension on BiometricCapability {
  String get displayName {
    switch (this) {
      case BiometricCapability.faceId:
        return 'Face ID';
      case BiometricCapability.fingerprint:
        return 'Fingerprint';
      case BiometricCapability.iris:
        return 'Iris Scan';
      case BiometricCapability.other:
        return 'Biometric';
      case BiometricCapability.notAvailable:
        return 'Not Available';
      case BiometricCapability.notEnrolled:
        return 'Not Set Up';
      case BiometricCapability.error:
        return 'Error';
    }
  }

  bool get isAvailable =>
      this != BiometricCapability.notAvailable &&
      this != BiometricCapability.notEnrolled &&
      this != BiometricCapability.error;
}
