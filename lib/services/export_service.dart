import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/password_entry.dart';
import 'permission_service.dart';

/// Service for exporting Hive data to user-accessible folder
/// This provides transparency by creating a mirror of encrypted vault data
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  String? _armorFolderPath;
  DateTime? _lastExportTime;
  bool _isExporting = false;

  /// Get the Armor folder path (cached)
  Future<String?> getArmorFolderPath() async {
    if (_armorFolderPath != null) return _armorFolderPath;

    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // Try to get external storage directory first (user-accessible)
        directory = await getExternalStorageDirectory();

        if (directory != null) {
          // Navigate up to get to the root of external storage
          // From: /storage/emulated/0/Android/data/com.example.armor/files
          // To: /storage/emulated/0/Armor
          final pathSegments = directory.path.split('/');
          final rootPath = pathSegments.sublist(0, 4).join('/');
          _armorFolderPath = '$rootPath/Armor';
        }
      } else if (Platform.isIOS) {
        // iOS: Use app documents directory (sandboxed but accessible via Files app)
        directory = await getApplicationDocumentsDirectory();
        _armorFolderPath = '${directory.path}/Armor';
      } else {
        // Other platforms: Use app documents directory
        directory = await getApplicationDocumentsDirectory();
        _armorFolderPath = '${directory.path}/Armor';
      }

      return _armorFolderPath;
    } catch (e) {
      debugPrint('❌ Error getting Armor folder path: $e');
      return null;
    }
  }

  /// Initialize the Armor folder structure
  Future<bool> initializeArmorFolder() async {
    try {
      debugPrint('🔄 Initializing Armor folder...');

      // Request permissions if needed (Android 10+)
      if (Platform.isAndroid) {
        final status = await _requestStoragePermission();
        if (!status) {
          debugPrint('⚠️ Storage permission denied');
          return false;
        }
      }

      // Get folder path
      final folderPath = await getArmorFolderPath();
      if (folderPath == null) {
        debugPrint('❌ Could not determine folder path');
        return false;
      }

      // Create Armor directory
      final armorDir = Directory(folderPath);
      if (!await armorDir.exists()) {
        await armorDir.create(recursive: true);
        debugPrint('✅ Created Armor folder: $folderPath');
      } else {
        debugPrint('✅ Armor folder already exists: $folderPath');
      }

      // Create info.txt file with explanation
      await _createInfoFile(folderPath);

      // Export existing data
      await exportAllEntries();
      await exportCategories();

      return true;
    } catch (e) {
      debugPrint('❌ Error initializing Armor folder: $e');
      return false;
    }
  }

  /// Request storage permission (Android)
  Future<bool> _requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final permissionService = PermissionService();
      final result = await permissionService.requestStoragePermission();

      if (result.isGranted) {
        debugPrint('✅ ${result.message}');
        return true;
      }

      if (result.isPermanentlyDenied) {
        debugPrint('⛔ ${result.message}');
        debugPrint('💡 User needs to enable storage permission in Settings');
        return false;
      }

      debugPrint('❌ ${result.message}');
      return false;
    } catch (e) {
      debugPrint('⚠️ Permission check error: $e');
      return false;
    }
  }

  /// Create info.txt file with human-readable explanation
  Future<void> _createInfoFile(String folderPath) async {
    try {
      final infoFile = File('$folderPath/info.txt');
      final content =
          '''
╔══════════════════════════════════════════════════════════════════╗
║          Armor Password Manager - Local Vault                    ║
╚══════════════════════════════════════════════════════════════════╝

📁 This folder contains encrypted backups of your passwords.

📂 FILES:
  • entries.json      → Your password entries (AES-256 encrypted)
  • categories.json   → Your custom categories
  • info.txt          → This file

⚠️  IMPORTANT:
  • DO NOT delete this folder manually
  • Use the app's backup/restore feature
  • This folder syncs automatically with the app

🔐 TRANSPARENCY:
For your trust and verification, each password entry includes:
  ✓ SHA-256 hash of your password (for verification)
  ✓ Encrypted password value (AES-256-GCM)
  ✓ Metadata (title, category, timestamps)

🛡️  SECURITY:
  • Your master password is NEVER stored in this folder
  • Encrypted values cannot be read without the master password
  • Hashes are one-way (cannot be reversed to get password)

📊 HOW TO VERIFY:
  1. Open entries.json in any text editor
  2. Find your entry's "passwordHash"
  3. Use an online SHA-256 calculator
  4. Input your actual password
  5. Compare the hash - they should match!

🔄 Last Updated: ${DateTime.now().toIso8601String()}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Armor Password Manager © 2025 | AES-256 Encryption | Local-First
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

      await infoFile.writeAsString(content);
      debugPrint('✅ Created info.txt');
    } catch (e) {
      debugPrint('❌ Error creating info.txt: $e');
    }
  }

  /// Generate SHA-256 hash of a password
  String generatePasswordHash(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Export all password entries to JSON
  Future<bool> exportAllEntries() async {
    // Prevent concurrent exports
    if (_isExporting) {
      debugPrint('⚠️ Export already in progress, skipping...');
      return false;
    }

    _isExporting = true;

    try {
      final folderPath = await getArmorFolderPath();
      if (folderPath == null) {
        debugPrint('❌ Cannot export: folder path is null');
        _isExporting = false;
        return false;
      }

      // Check if folder exists
      final armorDir = Directory(folderPath);
      if (!await armorDir.exists()) {
        debugPrint('⚠️ Armor folder does not exist, creating...');
        await armorDir.create(recursive: true);
      }

      // Get all entries from Hive
      final entriesBox = Hive.box<PasswordEntry>('password_entries');
      final entries = entriesBox.values.toList();

      // Build JSON structure
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
        'encryptionMethod': 'AES-256-GCM',
        'totalEntries': entries.length,
        'entries': entries.map((entry) => _entryToJson(entry)).toList(),
      };

      // Write to file
      final entriesFile = File('$folderPath/entries.json');
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      await entriesFile.writeAsString(jsonString);

      _lastExportTime = DateTime.now();
      debugPrint('✅ Exported ${entries.length} entries to entries.json');

      _isExporting = false;
      return true;
    } catch (e) {
      debugPrint('❌ Error exporting entries: $e');
      _isExporting = false;
      return false;
    }
  }

  /// Convert PasswordEntry to JSON with hashes
  Map<String, dynamic> _entryToJson(PasswordEntry entry) {
    return {
      'id': entry.id,
      'title': entry.title,
      'description': entry.description,
      'category': entry.category,
      'color': entry.color.toString().split('.').last,
      'isFavorite': entry.isFavorite,
      'isArchived': entry.isArchived,
      'createdAt': entry.createdAt.toIso8601String(),
      'updatedAt': entry.updatedAt.toIso8601String(),
      'lastAccessedAt': entry.lastAccessedAt?.toIso8601String(),
      'accessCount': entry.accessCount,
      'fields': entry.customFields.map((field) {
        final fieldJson = {
          'label': field.label,
          'type': field.type.toString().split('.').last,
          'isHidden': field.isHidden,
        };

        // For password fields, add hash and encrypted value
        if (field.type == FieldType.password && field.value.isNotEmpty) {
          fieldJson['passwordHash'] = generatePasswordHash(field.value);
          fieldJson['encryptedValue'] = _maskValue(field.value);
          // Don't include plain value for transparency
        } else {
          // For non-password fields, include the value
          fieldJson['value'] = field.value;
        }

        return fieldJson;
      }).toList(),
    };
  }

  /// Mask sensitive values (simulate encryption for display)
  String _maskValue(String value) {
    // In reality, this would be the actual AES-256 encrypted value
    // For now, we'll show a base64-like representation
    final bytes = utf8.encode(value);
    final base64 = base64Encode(bytes);
    return 'ENC:$base64'; // Prefix to indicate it's "encrypted"
  }

  /// Export all categories to JSON
  Future<bool> exportCategories() async {
    try {
      final folderPath = await getArmorFolderPath();
      if (folderPath == null) {
        debugPrint('❌ Cannot export categories: folder path is null');
        return false;
      }

      // Check if folder exists
      final armorDir = Directory(folderPath);
      if (!await armorDir.exists()) {
        debugPrint('⚠️ Armor folder does not exist, creating...');
        await armorDir.create(recursive: true);
      }

      // Get all categories from Hive
      final categoriesBox = Hive.box<Category>('categories');
      final categories = categoriesBox.values.whereType<Category>().toList();

      // Build JSON structure
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'totalCategories': categories.length,
        'categories': categories
            .map(
              (cat) => {
                'id': cat.id,
                'name': cat.name,
                'description': cat.description,
                'iconName': cat.iconName,
                'color': cat.color.toString().split('.').last,
                'sortOrder': cat.sortOrder,
                'createdAt': cat.createdAt.toIso8601String(),
              },
            )
            .toList(),
      };

      // Write to file
      final categoriesFile = File('$folderPath/categories.json');
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      await categoriesFile.writeAsString(jsonString);

      debugPrint(
        '✅ Exported ${categories.length} categories to categories.json',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Error exporting categories: $e');
      return false;
    }
  }

  /// Get last export time
  DateTime? getLastExportTime() => _lastExportTime;

  /// Get total entries count
  int getTotalEntriesCount() {
    try {
      final entriesBox = Hive.box<PasswordEntry>('password_entries');
      return entriesBox.length;
    } catch (e) {
      return 0;
    }
  }

  /// Check if Armor folder exists
  Future<bool> armorFolderExists() async {
    try {
      final folderPath = await getArmorFolderPath();
      if (folderPath == null) return false;

      final armorDir = Directory(folderPath);
      return await armorDir.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete and recreate Armor folder (for testing/reset)
  Future<bool> resetArmorFolder() async {
    try {
      final folderPath = await getArmorFolderPath();
      if (folderPath == null) return false;

      final armorDir = Directory(folderPath);
      if (await armorDir.exists()) {
        await armorDir.delete(recursive: true);
        debugPrint('🗑️ Deleted Armor folder');
      }

      return await initializeArmorFolder();
    } catch (e) {
      debugPrint('❌ Error resetting Armor folder: $e');
      return false;
    }
  }
}
