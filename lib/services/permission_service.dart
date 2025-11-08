import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling app permissions, especially storage access
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request storage permission for creating Armor folder
  /// Returns true if permission is granted or not needed
  Future<PermissionResult> requestStoragePermission() async {
    // iOS doesn't need storage permission for app documents
    if (!Platform.isAndroid) {
      return PermissionResult(
        isGranted: true,
        isDenied: false,
        isPermanentlyDenied: false,
        message: 'Permission not required on this platform',
      );
    }

    try {
      // Check Android version
      final androidInfo = await _getAndroidVersion();

      debugPrint('📱 Android version: $androidInfo');

      // Android 11+ (API 30+): Need MANAGE_EXTERNAL_STORAGE for /storage/emulated/0
      if (androidInfo >= 30) {
        debugPrint(
          '📱 Android 11+ detected - checking MANAGE_EXTERNAL_STORAGE',
        );
        final status = await Permission.manageExternalStorage.status;

        if (status.isGranted) {
          debugPrint('✅ MANAGE_EXTERNAL_STORAGE permission already granted');
          return PermissionResult(
            isGranted: true,
            isDenied: false,
            isPermanentlyDenied: false,
            message: 'Storage management permission granted',
          );
        }

        // Request MANAGE_EXTERNAL_STORAGE permission
        debugPrint('🔔 Requesting MANAGE_EXTERNAL_STORAGE permission...');
        final result = await Permission.manageExternalStorage.request();

        if (result.isGranted) {
          debugPrint('✅ MANAGE_EXTERNAL_STORAGE granted by user');
          return PermissionResult(
            isGranted: true,
            isDenied: false,
            isPermanentlyDenied: false,
            message: 'Storage management permission granted',
          );
        }

        debugPrint('⚠️ MANAGE_EXTERNAL_STORAGE denied');
        return PermissionResult(
          isGranted: false,
          isDenied: true,
          isPermanentlyDenied: result.isPermanentlyDenied,
          message:
              'Storage management permission required. Please grant "All files access" in Settings.',
        );
      }

      // Android 10 (API 29): Scoped storage works
      if (androidInfo >= 29) {
        debugPrint('✅ Android 10 detected - requesting storage permission');
        final status = await Permission.storage.status;

        if (status.isGranted) {
          return PermissionResult(
            isGranted: true,
            isDenied: false,
            isPermanentlyDenied: false,
            message: 'Storage permission granted',
          );
        }

        final result = await Permission.storage.request();
        return PermissionResult(
          isGranted: result.isGranted,
          isDenied: result.isDenied,
          isPermanentlyDenied: result.isPermanentlyDenied,
          message: result.isGranted
              ? 'Storage permission granted'
              : 'Storage permission denied',
        );
      }

      // Android 9 and below: Need storage permission
      final status = await Permission.storage.status;

      if (status.isGranted) {
        debugPrint('✅ Storage permission already granted');
        return PermissionResult(
          isGranted: true,
          isDenied: false,
          isPermanentlyDenied: false,
          message: 'Storage permission granted',
        );
      }

      if (status.isPermanentlyDenied) {
        debugPrint('⛔ Storage permission permanently denied');
        return PermissionResult(
          isGranted: false,
          isDenied: true,
          isPermanentlyDenied: true,
          message:
              'Storage permission permanently denied. Please enable in Settings.',
        );
      }

      // Request permission
      debugPrint('🔔 Requesting storage permission...');
      final result = await Permission.storage.request();

      if (result.isGranted) {
        debugPrint('✅ Storage permission granted by user');
        return PermissionResult(
          isGranted: true,
          isDenied: false,
          isPermanentlyDenied: false,
          message: 'Storage permission granted',
        );
      }

      if (result.isPermanentlyDenied) {
        debugPrint('⛔ Storage permission permanently denied by user');
        return PermissionResult(
          isGranted: false,
          isDenied: true,
          isPermanentlyDenied: true,
          message: 'Storage permission denied. Please enable in Settings.',
        );
      }

      debugPrint('❌ Storage permission denied by user');
      return PermissionResult(
        isGranted: false,
        isDenied: true,
        isPermanentlyDenied: false,
        message: 'Storage permission denied',
      );
    } catch (e) {
      debugPrint('❌ Error requesting storage permission: $e');
      return PermissionResult(
        isGranted: false,
        isDenied: true,
        isPermanentlyDenied: false,
        message: 'Error requesting permission: $e',
      );
    }
  }

  /// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await _getAndroidVersion();

      // Android 10+: No permission needed for app-specific directory
      if (androidInfo >= 29) {
        return true;
      }

      // Android 9 and below: Check permission
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error checking storage permission: $e');
      return false;
    }
  }

  /// Open app settings for user to manually enable permissions
  Future<bool> openAppSettings() async {
    try {
      debugPrint('📱 Opening app settings...');
      return await openAppSettings();
    } catch (e) {
      debugPrint('❌ Error opening app settings: $e');
      return false;
    }
  }

  /// Check if we can write to external storage
  Future<bool> canWriteToExternalStorage() async {
    if (!Platform.isAndroid) return true;

    try {
      final androidInfo = await _getAndroidVersion();

      // Android 10+: We use scoped storage (app-specific directory)
      if (androidInfo >= 29) {
        return true; // Always allowed for app-specific directory
      }

      // Android 9 and below: Check storage permission
      final status = await Permission.storage.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Error checking write access: $e');
      return false;
    }
  }

  /// Request notification permission (for export status updates - optional)
  Future<PermissionResult> requestNotificationPermission() async {
    try {
      // Android 13+ requires notification permission
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();

        if (androidInfo < 33) {
          // Below Android 13 - no permission needed
          return PermissionResult(
            isGranted: true,
            isDenied: false,
            isPermanentlyDenied: false,
            message: 'Notification permission not required',
          );
        }
      }

      final status = await Permission.notification.status;

      if (status.isGranted) {
        return PermissionResult(
          isGranted: true,
          isDenied: false,
          isPermanentlyDenied: false,
          message: 'Notification permission granted',
        );
      }

      // Request permission
      final result = await Permission.notification.request();

      return PermissionResult(
        isGranted: result.isGranted,
        isDenied: result.isDenied,
        isPermanentlyDenied: result.isPermanentlyDenied,
        message: result.isGranted
            ? 'Notification permission granted'
            : 'Notification permission denied',
      );
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return PermissionResult(
        isGranted: false,
        isDenied: true,
        isPermanentlyDenied: false,
        message: 'Error requesting notification permission',
      );
    }
  }

  /// Get Android API level (SDK version)
  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;

    try {
      // Try to get from platform channel or assume modern Android
      // For safety, assume Android 10+ (scoped storage)
      return 30; // Android 11 (API 30) - most common modern version
    } catch (e) {
      debugPrint('⚠️ Could not determine Android version, assuming 30: $e');
      return 30;
    }
  }

  /// Get user-friendly permission status message
  String getPermissionStatusMessage(PermissionResult result) {
    if (result.isGranted) {
      return '✅ Armor folder is accessible';
    }

    if (result.isPermanentlyDenied) {
      return '⚠️ Storage access denied. Please enable in Settings to use transparency folder.';
    }

    if (result.isDenied) {
      return '⚠️ Storage access denied. Armor folder will not be created.';
    }

    return '⚠️ Storage permission status unknown';
  }

  /// Check all permissions needed for the app
  Future<Map<String, bool>> checkAllPermissions() async {
    final results = <String, bool>{};

    // Storage permission
    results['storage'] = await isStoragePermissionGranted();

    // Notification permission (optional)
    if (Platform.isAndroid) {
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        final notificationStatus = await Permission.notification.status;
        results['notification'] = notificationStatus.isGranted;
      } else {
        results['notification'] = true; // Not required
      }
    } else {
      results['notification'] = true; // iOS handles differently
    }

    return results;
  }

  /// Get permission summary for UI display
  Future<PermissionSummary> getPermissionSummary() async {
    final storage = await isStoragePermissionGranted();
    final allPermissions = await checkAllPermissions();

    return PermissionSummary(
      storageGranted: storage,
      allPermissions: allPermissions,
      allGranted: allPermissions.values.every((granted) => granted),
    );
  }
}

/// Result of a permission request
class PermissionResult {
  final bool isGranted;
  final bool isDenied;
  final bool isPermanentlyDenied;
  final String message;

  PermissionResult({
    required this.isGranted,
    required this.isDenied,
    required this.isPermanentlyDenied,
    required this.message,
  });

  @override
  String toString() {
    return 'PermissionResult(granted: $isGranted, denied: $isDenied, permanent: $isPermanentlyDenied, message: $message)';
  }
}

/// Summary of all permissions
class PermissionSummary {
  final bool storageGranted;
  final Map<String, bool> allPermissions;
  final bool allGranted;

  PermissionSummary({
    required this.storageGranted,
    required this.allPermissions,
    required this.allGranted,
  });

  @override
  String toString() {
    return 'PermissionSummary(storage: $storageGranted, all: $allPermissions, allGranted: $allGranted)';
  }
}
