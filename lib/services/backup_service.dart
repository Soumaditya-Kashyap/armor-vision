import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart' hide Category;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/password_entry.dart';
import '../models/app_settings.dart';
import 'database_service.dart';
import 'encryption_service.dart';

/// Backup file format version for future compatibility
const String kBackupVersion = '1.0.0';
const String kAppName = 'ARMOR';
const String kBackupFileExtension = '.armor';

/// Result of a backup operation
class BackupResult {
  final bool isSuccess;
  final String? filePath;
  final String? errorMessage;
  final int entriesCount;
  final int categoriesCount;
  final int fileSizeBytes;

  BackupResult._({
    required this.isSuccess,
    this.filePath,
    this.errorMessage,
    this.entriesCount = 0,
    this.categoriesCount = 0,
    this.fileSizeBytes = 0,
  });

  factory BackupResult.success({
    required String filePath,
    required int entriesCount,
    required int categoriesCount,
    required int fileSizeBytes,
  }) {
    return BackupResult._(
      isSuccess: true,
      filePath: filePath,
      entriesCount: entriesCount,
      categoriesCount: categoriesCount,
      fileSizeBytes: fileSizeBytes,
    );
  }

  factory BackupResult.failed(String errorMessage) {
    return BackupResult._(isSuccess: false, errorMessage: errorMessage);
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

/// Result of a restore operation
class RestoreResult {
  final bool isSuccess;
  final String? errorMessage;
  final int entriesRestored;
  final int categoriesRestored;
  final String? backupVersion;
  final DateTime? backupDate;

  RestoreResult._({
    required this.isSuccess,
    this.errorMessage,
    this.entriesRestored = 0,
    this.categoriesRestored = 0,
    this.backupVersion,
    this.backupDate,
  });

  factory RestoreResult.success({
    required int entriesRestored,
    required int categoriesRestored,
    String? backupVersion,
    DateTime? backupDate,
  }) {
    return RestoreResult._(
      isSuccess: true,
      entriesRestored: entriesRestored,
      categoriesRestored: categoriesRestored,
      backupVersion: backupVersion,
      backupDate: backupDate,
    );
  }

  factory RestoreResult.failed(String errorMessage) {
    return RestoreResult._(isSuccess: false, errorMessage: errorMessage);
  }
}

/// Validation result for backup files
class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? backupVersion;
  final String? appName;
  final DateTime? createdAt;
  final int? entriesCount;
  final int? categoriesCount;

  BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.backupVersion,
    this.appName,
    this.createdAt,
    this.entriesCount,
    this.categoriesCount,
  });
}

/// Service for creating and restoring encrypted backups
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final EncryptionService _encryptionService = EncryptionService();

  bool _isProcessing = false;

  /// Derive encryption key from master password using PBKDF2
  encrypt.Key _deriveKey(String masterPassword, Uint8List salt) {
    // Use PBKDF2 with SHA-256 to derive a 256-bit key
    final passwordBytes = utf8.encode(masterPassword);

    // Combine password with salt
    final combined = Uint8List.fromList([...passwordBytes, ...salt]);

    // Perform multiple iterations of hashing (PBKDF2-like)
    Digest hash = sha256.convert(combined);
    for (int i = 0; i < 100000; i++) {
      hash = sha256.convert([...hash.bytes, ...salt]);
    }

    return encrypt.Key(Uint8List.fromList(hash.bytes));
  }

  /// Generate cryptographically secure random bytes
  Uint8List _generateSecureRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (i) => random.nextInt(256)),
    );
  }

  /// Calculate checksum for data integrity
  String _calculateChecksum(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Create encrypted backup
  Future<BackupResult> createBackup(String masterPassword) async {
    if (_isProcessing) {
      return BackupResult.failed('Backup already in progress');
    }

    if (masterPassword.isEmpty) {
      return BackupResult.failed('Master password is required');
    }

    _isProcessing = true;

    try {
      debugPrint('🔄 Starting backup creation...');

      // Step 1: Collect all data from Hive
      debugPrint('📥 Collecting data from database...');
      final entries = await _databaseService.getAllPasswordEntries(
        includeArchived: true,
      );
      final categories = await _databaseService.getAllCategories();
      final settings = await _databaseService.getAppSettings();

      debugPrint(
        '✅ Found ${entries.length} entries, ${categories.length} categories',
      );

      // Step 2: Decrypt sensitive data for backup (in memory only)
      debugPrint('🔓 Preparing data for backup...');
      final entriesJson = await _entriesToJson(entries);
      final categoriesJson = _categoriesToJson(categories);
      final settingsJson = _settingsToJson(settings);

      // Step 3: Create backup payload
      final payload = {
        'entries': entriesJson,
        'categories': categoriesJson,
        'settings': settingsJson,
      };

      final payloadJson = jsonEncode(payload);
      final checksum = _calculateChecksum(payloadJson);

      // Step 4: Generate salt and IV for encryption
      final salt = _generateSecureRandomBytes(32);
      final iv = encrypt.IV.fromSecureRandom(16);

      // Step 5: Derive encryption key from master password
      debugPrint('🔐 Deriving encryption key...');
      final key = _deriveKey(masterPassword, salt);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      // Step 6: Encrypt the payload
      debugPrint('🔒 Encrypting backup data...');
      final encrypted = encrypter.encrypt(payloadJson, iv: iv);

      // Step 7: Create backup schema
      final backupSchema = {
        'app_name': kAppName,
        'backup_version': kBackupVersion,
        'app_version': '1.0.0',
        'created_timestamp': DateTime.now().toIso8601String(),
        'checksum': checksum,
        'salt': base64.encode(salt),
        'iv': base64.encode(iv.bytes),
        'entries_count': entries.length,
        'categories_count': categories.length,
        'encrypted_payload': encrypted.base64,
      };

      final backupJson = jsonEncode(backupSchema);
      final backupBytes = utf8.encode(backupJson);

      // Step 8: Save to file
      debugPrint('💾 Saving backup file...');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'armor_backup_$timestamp$kBackupFileExtension';
      final filePath = await _saveBackupFile(
        Uint8List.fromList(backupBytes),
        fileName,
      );

      if (filePath == null) {
        return BackupResult.failed('Failed to save backup file');
      }

      debugPrint('✅ Backup created successfully: $filePath');

      return BackupResult.success(
        filePath: filePath,
        entriesCount: entries.length,
        categoriesCount: categories.length,
        fileSizeBytes: backupBytes.length,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Backup failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return BackupResult.failed('Backup failed: ${e.toString()}');
    } finally {
      _isProcessing = false;
    }
  }

  /// Validate backup file before restore
  Future<BackupValidationResult> validateBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'Backup file not found',
        );
      }

      final content = await file.readAsString();
      final Map<String, dynamic> backupSchema;

      try {
        backupSchema = jsonDecode(content) as Map<String, dynamic>;
      } catch (e) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'Invalid backup file format',
        );
      }

      // Check required fields
      if (backupSchema['app_name'] != kAppName) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'This backup was not created by ARMOR',
        );
      }

      if (!backupSchema.containsKey('backup_version') ||
          !backupSchema.containsKey('encrypted_payload') ||
          !backupSchema.containsKey('salt') ||
          !backupSchema.containsKey('iv')) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'Backup file is corrupted or incomplete',
        );
      }

      // Check version compatibility
      final backupVersion = backupSchema['backup_version'] as String;
      if (!_isVersionCompatible(backupVersion)) {
        return BackupValidationResult(
          isValid: false,
          errorMessage:
              'Backup version $backupVersion is not compatible with this app version',
        );
      }

      return BackupValidationResult(
        isValid: true,
        backupVersion: backupVersion,
        appName: backupSchema['app_name'] as String?,
        createdAt: backupSchema['created_timestamp'] != null
            ? DateTime.tryParse(backupSchema['created_timestamp'] as String)
            : null,
        entriesCount: backupSchema['entries_count'] as int?,
        categoriesCount: backupSchema['categories_count'] as int?,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'Failed to validate backup: ${e.toString()}',
      );
    }
  }

  /// Restore from encrypted backup
  Future<RestoreResult> restoreBackup(
    String filePath,
    String masterPassword, {
    bool replaceExisting = false,
  }) async {
    if (_isProcessing) {
      return RestoreResult.failed('Restore already in progress');
    }

    if (masterPassword.isEmpty) {
      return RestoreResult.failed('Master password is required');
    }

    _isProcessing = true;

    try {
      debugPrint('🔄 Starting backup restore...');

      // Step 1: Read and parse backup file
      final file = File(filePath);
      if (!await file.exists()) {
        return RestoreResult.failed('Backup file not found');
      }

      final content = await file.readAsString();
      final Map<String, dynamic> backupSchema;

      try {
        backupSchema = jsonDecode(content) as Map<String, dynamic>;
      } catch (e) {
        return RestoreResult.failed('Invalid backup file format');
      }

      // Step 2: Validate backup
      final validation = await validateBackup(filePath);
      if (!validation.isValid) {
        return RestoreResult.failed(
          validation.errorMessage ?? 'Invalid backup',
        );
      }

      // Step 3: Extract encryption parameters
      final salt = base64.decode(backupSchema['salt'] as String);
      final ivBytes = base64.decode(backupSchema['iv'] as String);
      final iv = encrypt.IV(ivBytes);
      final encryptedPayload = backupSchema['encrypted_payload'] as String;
      final storedChecksum = backupSchema['checksum'] as String?;

      // Step 4: Derive key and decrypt
      debugPrint('🔐 Deriving decryption key...');
      final key = _deriveKey(masterPassword, Uint8List.fromList(salt));
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      String decryptedPayload;
      try {
        debugPrint('🔓 Decrypting backup data...');
        decryptedPayload = encrypter.decrypt64(encryptedPayload, iv: iv);
      } catch (e) {
        return RestoreResult.failed(
          'Incorrect master password or corrupted backup',
        );
      }

      // Step 5: Verify checksum
      if (storedChecksum != null) {
        final calculatedChecksum = _calculateChecksum(decryptedPayload);
        if (calculatedChecksum != storedChecksum) {
          return RestoreResult.failed('Backup data integrity check failed');
        }
        debugPrint('✅ Data integrity verified');
      }

      // Step 6: Parse payload
      final Map<String, dynamic> payload;
      try {
        payload = jsonDecode(decryptedPayload) as Map<String, dynamic>;
      } catch (e) {
        return RestoreResult.failed('Failed to parse backup data');
      }

      // Step 7: Clear existing data if replace mode
      if (replaceExisting) {
        debugPrint('🗑️ Clearing existing data...');
        await _clearAllData();
      }

      // Step 8: Restore data
      debugPrint('📥 Restoring data...');
      int entriesRestored = 0;
      int categoriesRestored = 0;

      // Restore categories first (entries may reference them)
      if (payload.containsKey('categories')) {
        final categoriesList = payload['categories'] as List<dynamic>;
        for (final categoryJson in categoriesList) {
          try {
            final category = _categoryFromJson(
              categoryJson as Map<String, dynamic>,
            );
            await _databaseService.saveCategory(category);
            categoriesRestored++;
          } catch (e) {
            debugPrint('⚠️ Failed to restore category: $e');
          }
        }
        debugPrint('✅ Restored $categoriesRestored categories');
      }

      // Restore entries
      if (payload.containsKey('entries')) {
        final entriesList = payload['entries'] as List<dynamic>;
        for (final entryJson in entriesList) {
          try {
            final entry = await _entryFromJson(
              entryJson as Map<String, dynamic>,
            );
            await _databaseService.savePasswordEntry(entry);
            entriesRestored++;
          } catch (e) {
            debugPrint('⚠️ Failed to restore entry: $e');
          }
        }
        debugPrint('✅ Restored $entriesRestored entries');
      }

      // Restore settings (optional - might want to keep current settings)
      // if (payload.containsKey('settings') && replaceExisting) {
      //   final settingsJson = payload['settings'] as Map<String, dynamic>;
      //   final settings = _settingsFromJson(settingsJson);
      //   await _databaseService.saveAppSettings(settings);
      // }

      debugPrint('✅ Restore completed successfully!');

      return RestoreResult.success(
        entriesRestored: entriesRestored,
        categoriesRestored: categoriesRestored,
        backupVersion: validation.backupVersion,
        backupDate: validation.createdAt,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Restore failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return RestoreResult.failed('Restore failed: ${e.toString()}');
    } finally {
      _isProcessing = false;
    }
  }

  /// Share backup file
  Future<bool> shareBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'ARMOR Password Manager Backup',
        text: 'This is an encrypted backup file from ARMOR Password Manager.',
      );

      return true;
    } catch (e) {
      debugPrint('❌ Failed to share backup: $e');
      return false;
    }
  }

  /// Check version compatibility
  bool _isVersionCompatible(String backupVersion) {
    // For now, accept version 1.x.x
    final parts = backupVersion.split('.');
    if (parts.isEmpty) return false;

    final majorVersion = int.tryParse(parts[0]);
    return majorVersion == 1;
  }

  /// Clear all data from database
  Future<void> _clearAllData() async {
    try {
      // Get all entries and delete them
      final entries = await _databaseService.getAllPasswordEntries(
        includeArchived: true,
      );
      for (final entry in entries) {
        await _databaseService.deletePasswordEntry(entry.id);
      }

      // Note: Categories are handled separately
      // We'll keep preset categories but remove custom ones
    } catch (e) {
      debugPrint('⚠️ Error clearing data: $e');
    }
  }

  /// Convert entries to JSON with decrypted passwords
  Future<List<Map<String, dynamic>>> _entriesToJson(
    List<PasswordEntry> entries,
  ) async {
    final result = <Map<String, dynamic>>[];

    for (final entry in entries) {
      final fieldsJson = <Map<String, dynamic>>[];

      for (final field in entry.customFields) {
        String value = field.value;
        // Decrypt hidden fields (passwords, PINs, etc.)
        if (field.isHidden && value.isNotEmpty) {
          try {
            value = _encryptionService.decrypt(value);
          } catch (e) {
            // If decryption fails, use the original value
            debugPrint('⚠️ Could not decrypt field ${field.label}: $e');
          }
        }

        fieldsJson.add({
          'label': field.label,
          'value': value,
          'type': field.type.index,
          'isRequired': field.isRequired,
          'isHidden': field.isHidden,
          'sortOrder': field.sortOrder,
          'isCopyable': field.isCopyable,
          'hint': field.hint,
        });
      }

      result.add({
        'id': entry.id,
        'title': entry.title,
        'description': entry.description,
        'customFields': fieldsJson,
        'createdAt': entry.createdAt.toIso8601String(),
        'updatedAt': entry.updatedAt.toIso8601String(),
        'category': entry.category,
        'isFavorite': entry.isFavorite,
        'imagePath': entry.imagePath,
        'tags': entry.tags,
        'color': entry.color.index,
        'accessCount': entry.accessCount,
        'lastAccessedAt': entry.lastAccessedAt?.toIso8601String(),
        'isArchived': entry.isArchived,
        'notes': entry.notes,
      });
    }

    return result;
  }

  /// Convert entry from JSON and encrypt passwords
  Future<PasswordEntry> _entryFromJson(Map<String, dynamic> json) async {
    final fieldsJson = json['customFields'] as List<dynamic>;
    final customFields = <CustomField>[];

    for (final fieldJson in fieldsJson) {
      final field = fieldJson as Map<String, dynamic>;
      String value = field['value'] as String? ?? '';

      // Encrypt hidden fields before storing
      if (field['isHidden'] == true && value.isNotEmpty) {
        try {
          value = _encryptionService.encrypt(value);
        } catch (e) {
          debugPrint('⚠️ Could not encrypt field: $e');
        }
      }

      customFields.add(
        CustomField(
          label: field['label'] as String? ?? '',
          value: value,
          type: FieldType.values[field['type'] as int? ?? 0],
          isRequired: field['isRequired'] as bool? ?? false,
          isHidden: field['isHidden'] as bool? ?? false,
          sortOrder: field['sortOrder'] as int? ?? 0,
          isCopyable: field['isCopyable'] as bool? ?? true,
          hint: field['hint'] as String?,
        ),
      );
    }

    return PasswordEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      customFields: customFields,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      category: json['category'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      imagePath: json['imagePath'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      color: EntryColor.values[json['color'] as int? ?? 0],
      accessCount: json['accessCount'] as int? ?? 0,
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.tryParse(json['lastAccessedAt'] as String)
          : null,
      isArchived: json['isArchived'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Convert categories to JSON
  List<Map<String, dynamic>> _categoriesToJson(List<Category> categories) {
    return categories.map((category) {
      return {
        'id': category.id,
        'name': category.name,
        'description': category.description,
        'color': category.color.index,
        'iconName': category.iconName,
        'createdAt': category.createdAt.toIso8601String(),
        'sortOrder': category.sortOrder,
      };
    }).toList();
  }

  /// Convert category from JSON
  Category _categoryFromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: EntryColor.values[json['color'] as int? ?? 0],
      iconName: json['iconName'] as String? ?? 'folder',
      createdAt: DateTime.parse(json['createdAt'] as String),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  /// Convert settings to JSON
  Map<String, dynamic> _settingsToJson(AppSettings settings) {
    return {
      'isDarkMode': settings.isDarkMode,
      'isBiometricEnabled': settings.isBiometricEnabled,
      'autoLockTimeoutMinutes': settings.autoLockTimeoutMinutes,
      'defaultCategory': settings.defaultCategory,
      'defaultSortOption': settings.defaultSortOption.index,
      'defaultViewMode': settings.defaultViewMode.index,
      'showPasswordStrength': settings.showPasswordStrength,
      'enableAutoBackup': settings.enableAutoBackup,
      'maxBackupFiles': settings.maxBackupFiles,
      'enableHapticFeedback': settings.enableHapticFeedback,
      'securityLevel': settings.securityLevel.index,
    };
  }

  /// Save backup file to storage
  Future<String?> _saveBackupFile(Uint8List bytes, String fileName) async {
    try {
      Directory exportDir;

      if (Platform.isAndroid) {
        // Android: Use Downloads/Armor/Backups directory
        final downloadDir = Directory('/storage/emulated/0/Download');
        exportDir = Directory('${downloadDir.path}/Armor/Backups');
      } else if (Platform.isIOS) {
        // iOS: Use app documents directory
        final docDir = await getApplicationDocumentsDirectory();
        exportDir = Directory('${docDir.path}/Backups');
      } else {
        // Desktop: Use documents directory
        final docDir = await getApplicationDocumentsDirectory();
        exportDir = Directory('${docDir.path}/Armor/Backups');
      }

      // Create directory if it doesn't exist
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final filePath = '${exportDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      debugPrint('❌ Failed to save backup file: $e');
      return null;
    }
  }

  /// Get list of existing backups
  Future<List<BackupFileInfo>> getExistingBackups() async {
    try {
      Directory backupDir;

      if (Platform.isAndroid) {
        backupDir = Directory('/storage/emulated/0/Download/Armor/Backups');
      } else if (Platform.isIOS) {
        final docDir = await getApplicationDocumentsDirectory();
        backupDir = Directory('${docDir.path}/Backups');
      } else {
        final docDir = await getApplicationDocumentsDirectory();
        backupDir = Directory('${docDir.path}/Armor/Backups');
      }

      if (!await backupDir.exists()) {
        return [];
      }

      final files = await backupDir
          .list()
          .where((entity) => entity.path.endsWith(kBackupFileExtension))
          .toList();

      final backups = <BackupFileInfo>[];
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          backups.add(
            BackupFileInfo(
              filePath: entity.path,
              fileName: entity.path.split('/').last,
              fileSize: stat.size,
              createdAt: stat.modified,
            ),
          );
        }
      }

      // Sort by date, newest first
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return backups;
    } catch (e) {
      debugPrint('❌ Failed to get existing backups: $e');
      return [];
    }
  }

  /// Delete a backup file
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Failed to delete backup: $e');
      return false;
    }
  }

  bool get isProcessing => _isProcessing;
}

/// Information about a backup file
class BackupFileInfo {
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime createdAt;

  BackupFileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
  });

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
