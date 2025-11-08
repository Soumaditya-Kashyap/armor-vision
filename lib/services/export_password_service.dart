import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
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

      // Step 4: Generate formatted file content
      debugPrint('📝 Generating ${config.format.displayName} file...');
      final Uint8List fileBytes;

      switch (config.format) {
        case ExportFormat.txt:
          fileBytes = await generateTxtExport(decryptedEntries, config);
          break;
        case ExportFormat.pdf:
          fileBytes = await PdfGeneratorService().createPdf(
            decryptedEntries,
            config,
          );
          break;
      }

      debugPrint('✅ File generated: ${fileBytes.length} bytes');

      // Step 5: Save file directly (unencrypted)
      // Note: PDF/TXT files are saved as-is for easy viewing
      debugPrint('💾 Saving file...');
      final timestamp = _getTimestamp();
      final fileName = config.format == ExportFormat.pdf
          ? 'armor_export_$timestamp.pdf'
          : 'armor_export_$timestamp.txt';

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
  /// Format is clean and easy to read, suitable for printing or backup
  Future<Uint8List> generateTxtExport(
    List<Map<String, dynamic>> entries,
    ExportConfig config,
  ) async {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('=' * 70);
    buffer.writeln('ARMOR PASSWORD MANAGER - ENCRYPTED EXPORT');
    buffer.writeln('=' * 70);
    buffer.writeln();
    buffer.writeln(
      'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
    );
    buffer.writeln('Total Entries: ${entries.length}');
    buffer.writeln('Format: Plain Text (TXT)');
    buffer.writeln('Encryption: AES-256-GCM');
    buffer.writeln();
    buffer.writeln('=' * 70);
    buffer.writeln();
    buffer.writeln('🔒 ENCRYPTION NOTICE');
    buffer.writeln('-' * 70);
    buffer.writeln('This file is encrypted with AES-256-GCM encryption.');
    buffer.writeln(
      'You will need the password you set during export to decrypt it.',
    );
    buffer.writeln('Keep this password safe and separate from this file.');
    buffer.writeln();
    buffer.writeln('⚠️  SECURITY WARNING');
    buffer.writeln('-' * 70);
    buffer.writeln('• Store this file in a secure location');
    buffer.writeln(
      '• Do NOT share the decryption password via insecure channels',
    );
    buffer.writeln(
      '• Delete this file after importing to another password manager',
    );
    buffer.writeln(
      '• Consider storing on encrypted USB drive or secure cloud storage',
    );
    buffer.writeln();
    buffer.writeln('=' * 70);
    buffer.writeln();

    // Entries
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];

      buffer.writeln();
      buffer.writeln('━' * 70);
      buffer.writeln('ENTRY #${i + 1}: ${entry['title']}');
      buffer.writeln('━' * 70);
      buffer.writeln();

      // Metadata
      if (entry['category'] != null &&
          entry['category'].toString().isNotEmpty) {
        buffer.writeln('Category: ${entry['category']}');
      }

      if (entry['description'] != null &&
          entry['description'].toString().isNotEmpty) {
        buffer.writeln('Description: ${entry['description']}');
      }

      buffer.writeln('Created: ${_formatDate(entry['createdAt'])}');
      buffer.writeln('Last Modified: ${_formatDate(entry['updatedAt'])}');

      if (entry['lastAccessedAt'] != null) {
        buffer.writeln(
          'Last Accessed: ${_formatDate(entry['lastAccessedAt'])}',
        );
      }

      buffer.writeln('Access Count: ${entry['accessCount'] ?? 0}');
      buffer.writeln('Favorite: ${entry['isFavorite'] ? 'Yes ⭐' : 'No'}');

      if (entry['isArchived']) {
        buffer.writeln('Status: 📦 Archived');
      }

      // Fields
      buffer.writeln();
      buffer.writeln('Credentials & Information:');
      buffer.writeln('-' * 70);

      final fields = entry['fields'] as List<Map<String, dynamic>>;
      for (final field in fields) {
        final label = field['label'] as String;
        final value = field['value'] as String;
        final isHidden = field['isHidden'] as bool;

        final securityIcon = isHidden ? '🔐' : '📝';
        final requiredMark = (field['isRequired'] as bool) ? '*' : '';

        buffer.writeln('  $securityIcon $label$requiredMark: $value');
      }

      // Tags
      if (config.includeTags && entry['tags'] != null) {
        final tags = entry['tags'] as List<String>;
        if (tags.isNotEmpty) {
          buffer.writeln();
          buffer.writeln('Tags: ${tags.join(', ')}');
        }
      }

      // Notes (from the Notes field, not description)
      if (config.includeNotes && entry['notes'] != null) {
        final notes = entry['notes'] as String;
        if (notes.isNotEmpty) {
          buffer.writeln();
          buffer.writeln('📝 Notes:');
          buffer.writeln('  $notes');
        }
      }

      buffer.writeln();
      buffer.writeln('-' * 70);
    }

    // Footer
    buffer.writeln();
    buffer.writeln('=' * 70);
    buffer.writeln('END OF EXPORT');
    buffer.writeln('=' * 70);
    buffer.writeln();
    buffer.writeln('Exported from Armor Password Manager');
    buffer.writeln('https://github.com/your-repo/armor');
    buffer.writeln();

    // Convert to bytes
    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

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

  /// Format DateTime for display
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    if (date is DateTime) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    return date.toString();
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
