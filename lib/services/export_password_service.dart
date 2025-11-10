import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/password_entry.dart';
import '../models/export_models.dart';
import 'database_service.dart';
import 'encryption_service.dart';
import 'pdf_generator_service.dart';

/// Service for exporting passwords as encrypted files
class ExportPasswordService {
  static final ExportPasswordService _instance =
      ExportPasswordService._internal();
  factory ExportPasswordService() => _instance;
  ExportPasswordService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final EncryptionService _encryptionService = EncryptionService();

  bool _isExporting = false;

  /// Main export orchestrator
  ///
  /// Exports all password entries to an encrypted file
  /// Returns ExportResult with status and file information
  Future<ExportResult> exportPasswords(ExportConfig config) async {
    if (_isExporting) {
      return ExportResult.failed(
        errorMessage: 'Export already in progress',
        format: config.format,
      );
    }

    _isExporting = true;

    try {
      debugPrint('🔄 Starting password export...');
      debugPrint('📄 Format: ${config.format.displayName}');
      debugPrint(
        '⚠️  Note: Exported as plain ${config.format.displayName.toUpperCase()} file (password not stored in file)',
      );

      // Step 1: Validate configuration
      if (!config.isValid) {
        return ExportResult.failed(
          errorMessage: config.validationError ?? 'Invalid configuration',
          format: config.format,
        );
      }

      // Step 2: Fetch all password entries from database
      debugPrint(
        '📥 Fetching password entries (includeArchived: ${config.includeArchived})...',
      );
      final entries = await _databaseService.getAllPasswordEntries(
        includeArchived: config.includeArchived,
      );

      if (entries.isEmpty) {
        return ExportResult.failed(
          errorMessage: 'No password entries to export',
          format: config.format,
        );
      }

      debugPrint('✅ Found ${entries.length} entries to export');
      for (int i = 0; i < entries.length; i++) {
        debugPrint(
          '   Entry ${i + 1}: ${entries[i].title} (archived: ${entries[i].isArchived})',
        );
      }

      // Step 3: Decrypt passwords in memory (for export only)
      debugPrint('🔓 Decrypting passwords in memory...');
      final decryptedEntries = await _decryptEntriesInMemory(entries);

      // Step 4: Generate PDF file
      debugPrint('📝 Generating password-protected PDF...');
      final Uint8List fileBytes = await PdfGeneratorService().createPdf(
        decryptedEntries,
        config,
        password: config.password, // Pass password for PDF encryption
      );

      debugPrint('✅ PDF generated: ${fileBytes.length} bytes');

      // Step 5: Handle destination
      if (config.destination == ExportDestination.email) {
        // TODO: Implement email export
        debugPrint('📧 Email export not yet implemented');
        throw Exception('Email export feature is coming soon!');
      }

      // Save to device
      debugPrint('💾 Saving file to device...');
      final timestamp = _getTimestamp();
      final fileName = 'armor_export_$timestamp.pdf';

      final filePath = await saveExportedFile(fileBytes, fileName);

      if (filePath == null) {
        return ExportResult.failed(
          errorMessage: 'Failed to save file to storage',
          format: config.format,
        );
      }

      debugPrint('✅ Export complete: $filePath');

      // Clear decrypted data from memory
      decryptedEntries.clear();

      return ExportResult.success(
        filePath: filePath,
        fileSizeBytes: fileBytes.length,
        format: config.format,
        entriesExported: entries.length,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Export failed: $e');
      debugPrint('Stack trace: $stackTrace');

      return ExportResult.failed(
        errorMessage: 'Export failed: ${e.toString()}',
        format: config.format,
      );
    } finally {
      _isExporting = false;
    }
  }

  /// Decrypt password entries in memory (for export only)
  ///
  /// Returns a list of entries with decrypted password fields
  /// WARNING: Decrypted data is kept in memory - clear after use!
  Future<List<Map<String, dynamic>>> _decryptEntriesInMemory(
    List<PasswordEntry> entries,
  ) async {
    final decryptedEntries = <Map<String, dynamic>>[];

    for (final entry in entries) {
      final decryptedFields = <Map<String, dynamic>>[];

      // Decrypt each custom field
      for (final field in entry.customFields) {
        final decryptedValue = field.isHidden
            ? await _encryptionService.decrypt(field.value)
            : field.value;

        decryptedFields.add({
          'label': field.label,
          'value': decryptedValue,
          'type': field.type.name,
          'isHidden': field.isHidden,
          'isRequired': field.isRequired,
        });
      }

      decryptedEntries.add({
        'id': entry.id,
        'title': entry.title,
        'description': entry.description,
        'notes': entry.notes,
        'category': entry.category,
        'tags': entry.tags,
        'color': entry.color.name,
        'isFavorite': entry.isFavorite,
        'isArchived': entry.isArchived,
        'fields': decryptedFields,
        'createdAt': entry.createdAt,
        'updatedAt': entry.updatedAt,
        'lastAccessedAt': entry.lastAccessedAt,
        'accessCount': entry.accessCount,
      });
    }

    return decryptedEntries;
  }

  /// Generate TXT export file
  ///
  /// Creates a human-readable plain text file with all password entries
  /// Save exported file to device storage
  ///
  /// Android: /storage/emulated/0/Download/Armor/
  /// iOS: App Documents directory (accessible via Files app)
  /// Returns file path on success, null on failure
  Future<String?> saveExportedFile(Uint8List fileBytes, String fileName) async {
    try {
      Directory exportDir;

      if (Platform.isAndroid) {
        // Android: Use Downloads/Armor directory
        final downloadDir = Directory('/storage/emulated/0/Download');
        exportDir = Directory('${downloadDir.path}/Armor');
      } else if (Platform.isIOS) {
        // iOS: Use app documents directory
        final docDir = await getApplicationDocumentsDirectory();
        exportDir = Directory('${docDir.path}/Exports');
      } else {
        // Other platforms: Use app documents directory
        final docDir = await getApplicationDocumentsDirectory();
        exportDir = Directory('${docDir.path}/Exports');
      }

      // Create directory if it doesn't exist
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
        debugPrint('✅ Created export directory: ${exportDir.path}');
      }

      // Full file path
      final filePath = '${exportDir.path}/$fileName';

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      debugPrint('✅ File saved: $filePath');
      debugPrint('📏 File size: ${fileBytes.length} bytes');

      return filePath;
    } catch (e) {
      debugPrint('❌ Failed to save file: $e');
      return null;
    }
  }

  /// Get export directory path for display
  Future<String> getExportDirectoryPath() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/Armor';
    } else if (Platform.isIOS) {
      final docDir = await getApplicationDocumentsDirectory();
      return '${docDir.path}/Exports';
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      return '${docDir.path}/Exports';
    }
  }

  /// Check if currently exporting
  bool get isExporting => _isExporting;

  /// Generate timestamp for filename
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }
}
