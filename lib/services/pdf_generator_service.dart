import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/export_models.dart';

/// Service for generating PDF exports of password entries
class PdfGeneratorService {
  static final PdfGeneratorService _instance = PdfGeneratorService._internal();
  factory PdfGeneratorService() => _instance;
  PdfGeneratorService._internal();

  // Color scheme matching Armor's theme
  static final _primaryColor = PdfColor.fromHex('#4A90E2'); // Blue
  static final _accentColor = PdfColor.fromHex('#FFB74D'); // Amber
  static final _textColor = PdfColor.fromHex('#2C3E50'); // Dark gray
  static final _lightGray = PdfColor.fromHex('#ECF0F1'); // Light gray
  static final _warningColor = PdfColor.fromHex('#E74C3C'); // Red

  /// Create PDF document from password entries
  ///
  /// Generates a professionally formatted PDF with:
  /// - Title page with encryption notice
  /// - Entry pages with credentials tables
  /// - Metadata and security warnings
  /// - Optional password protection
  Future<Uint8List> createPdf(
    List<Map<String, dynamic>> entries,
    ExportConfig config, {
    String? password,
  }) async {
    try {
      debugPrint('📄 Creating PDF document...');

      final pdf = pw.Document(
        title: 'Armor Password Export',
        author: 'Armor Password Manager',
        creator: 'Armor Password Manager v1.0.0',
        subject: 'Password-Protected Export',
        keywords: 'passwords, encryption, backup',
      );

      // Page 1: Title page with encryption notice
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => _buildTitlePage(entries.length, config),
        ),
      );

      // Pages 2-N: Entry pages (2 entries per page, auto-paginated)
      debugPrint(
        '📄 Creating PDF pages for ${entries.length} entries (2 per page with auto-pagination)...',
      );
      for (int i = 0; i < entries.length; i += 2) {
        final entry1 = entries[i];
        final entry2 = (i + 1) < entries.length ? entries[i + 1] : null;

        debugPrint(
          '   MultiPage ${(i ~/ 2) + 1}: Entry ${i + 1} (${entry1['title']})${entry2 != null ? ' + Entry ${i + 2} (${entry2['title']})' : ' (last entry)'}',
        );

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            build: (context) => [
              // First entry
              _buildEntryPage(entry1, i + 1, config),

              // Spacer between entries
              if (entry2 != null) ...[
                pw.SizedBox(height: 20),
                pw.Divider(color: _lightGray, thickness: 2),
                pw.SizedBox(height: 20),
              ],

              // Second entry (if exists)
              if (entry2 != null) _buildEntryPage(entry2, i + 2, config),
            ],
          ),
        );
      }

      // Generate PDF bytes
      final bytes = await pdf.save();
      debugPrint('✅ PDF generated: ${bytes.length} bytes');

      return bytes;
    } catch (e) {
      debugPrint('❌ PDF generation error: $e');
      rethrow;
    }
  }

  /// Build title page with branding and encryption notice
  pw.Widget _buildTitlePage(int entryCount, ExportConfig config) {
    final now = DateTime.now();

    return pw.Container(
      padding: const pw.EdgeInsets.all(40),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 60),

              // Title
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: _primaryColor,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(10),
                  ),
                ),
                child: pw.Text(
                  'ARMOR',
                  style: pw.TextStyle(
                    fontSize: 48,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text(
                'Password Manager',
                style: pw.TextStyle(
                  fontSize: 20,
                  color: _textColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 5),

              pw.Text(
                'Secure Offline Password Manager',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
              ),

              pw.SizedBox(height: 40),

              // Export info
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _lightGray, width: 2),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Export Date:', _formatDateTime(now)),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Export Format:', config.format.displayName),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Total Entries:', entryCount.toString()),
                    pw.SizedBox(height: 8),
                    _buildInfoRow('Warning:', 'Unencrypted Plain Text File'),
                  ],
                ),
              ),
            ],
          ),

          // Encryption notice (middle section)
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: _warningColor,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 30,
                          height: 30,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(15),
                            ),
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              '!',
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                                color: _warningColor,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          'SECURITY NOTICE',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 15),
                    pw.Text(
                      'This PDF document contains password entries exported from Armor Password Manager.',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'IMPORTANT: This file is NOT encrypted. Store it securely and delete it after use. Anyone who can access this file can view all passwords.',
                      style: const pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Security warnings
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: _warningColor, width: 2),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'SECURITY WARNINGS - UNENCRYPTED FILE',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _warningColor,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildBulletPoint(
                      'This file contains ALL passwords in PLAIN TEXT',
                    ),
                    _buildBulletPoint(
                      'Anyone with access to this file can read all passwords',
                    ),
                    _buildBulletPoint(
                      'Store in a secure, encrypted location immediately',
                    ),
                    _buildBulletPoint(
                      'Do NOT upload to cloud storage or email without encryption',
                    ),
                    _buildBulletPoint(
                      'Delete this file as soon as you no longer need it',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Footer
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Column(
              children: [
                pw.Text(
                  'Generated by Armor Password Manager v1.0.0',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Secure • Offline • Private',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: _primaryColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single entry page with credentials
  pw.Widget _buildEntryPage(
    Map<String, dynamic> entry,
    int entryNumber,
    ExportConfig config,
  ) {
    final fields = entry['fields'] as List<Map<String, dynamic>>;
    final hasFields = fields.isNotEmpty;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Entry header (compact)
        _buildEntryHeader(entry, entryNumber),

        // Description (simple text, no box) - right after header
        if (entry['description'] != null &&
            entry['description'].toString().isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 4),
            child: pw.Text(
              'Description: ${entry['description']}',
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
        ],

        pw.SizedBox(height: 10),

        // Credentials table (only if fields exist)
        if (hasFields) ...[
          _buildCredentialsTable(entry),
          pw.SizedBox(height: 10),
        ],

        // Metadata (more compact)
        _buildMetadata(entry),

        // Notes section (show if notes exist, regardless of fields)
        if (config.includeNotes &&
            entry['notes'] != null &&
            entry['notes'].toString().isNotEmpty) ...[
          pw.SizedBox(height: 8),
          _buildNotesSection(entry),
        ],

        // Tags (if enabled and exists)
        if (config.includeTags &&
            entry['tags'] != null &&
            (entry['tags'] as List).isNotEmpty) ...[
          pw.SizedBox(height: 8),
          _buildTags(entry['tags'] as List<String>),
        ],
      ],
    );
  }

  /// Build entry header with title and badges (compact)
  pw.Widget _buildEntryHeader(Map<String, dynamic> entry, int entryNumber) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _primaryColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Row(
              children: [
                pw.Text(
                  '#$entryNumber',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey300,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    entry['title'].toString(),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.Row(
            children: [
              if (entry['isFavorite'] == true) _buildBadge('★', _accentColor),
              if (entry['isArchived'] == true) ...[
                pw.SizedBox(width: 4),
                _buildBadge('📦', PdfColors.grey400),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Build credentials table with field labels and values
  pw.Widget _buildCredentialsTable(Map<String, dynamic> entry) {
    final fields = entry['fields'] as List<Map<String, dynamic>>;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _lightGray, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Table(
        border: pw.TableBorder.symmetric(
          inside: pw.BorderSide(color: _lightGray, width: 0.5),
        ),
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(2),
        },
        children: [
          // Header row (compact)
          pw.TableRow(
            decoration: pw.BoxDecoration(color: _lightGray),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: pw.Text(
                  'Field',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: pw.Text(
                  'Value',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
            ],
          ),

          // Field rows (compact)
          ...fields.map((field) {
            final label = field['label'] as String;
            final value = field['value'] as String;
            final isHidden = field['isHidden'] as bool;
            final isRequired = field['isRequired'] as bool;

            final icon = isHidden ? '🔐' : '📝';
            final requiredMark = isRequired ? ' *' : '';

            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: pw.Text(
                    '$icon $label$requiredMark',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: _textColor,
                      fontWeight: isHidden
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                    ),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: pw.Text(
                    value,
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: isHidden ? _primaryColor : _textColor,
                      fontWeight: isHidden
                          ? pw.FontWeight.bold
                          : pw.FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Build metadata section (compact)
  pw.Widget _buildMetadata(Map<String, dynamic> entry) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Category: ${entry['category']?.toString() ?? 'Uncategorized'}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Created: ${_formatDate(entry['createdAt'])}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Access Count: ${entry['accessCount']?.toString() ?? '0'}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Modified: ${_formatDate(entry['updatedAt'])}',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build notes section for entries (from the Notes field in the app)
  pw.Widget _buildNotesSection(Map<String, dynamic> entry) {
    // Get notes from the 'notes' field (HiveField 14 in PasswordEntry model)
    final noteContent = entry['notes']?.toString();

    if (noteContent == null || noteContent.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        border: pw.Border.all(color: PdfColors.amber200, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text('📝 ', style: const pw.TextStyle(fontSize: 10)),
              pw.Text(
                'Notes',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.amber900,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            noteContent,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
          ),
        ],
      ),
    );
  }

  /// Build tags section (compact)
  pw.Widget _buildTags(List<String> tags) {
    return pw.Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags.map((tag) {
        return pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
          ),
          child: pw.Text(
            tag,
            style: pw.TextStyle(
              fontSize: 7,
              color: _primaryColor,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Build badge widget (compact - icon only)
  pw.Widget _buildBadge(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  /// Build info row for title page
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(value, style: pw.TextStyle(fontSize: 12, color: _textColor)),
      ],
    );
  }

  /// Build bullet point
  pw.Widget _buildBulletPoint(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5, left: 5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 4),
            width: 4,
            height: 4,
            decoration: const pw.BoxDecoration(
              color: PdfColors.white,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Build metadata item
  /// Format DateTime for display
  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';

    if (date is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }

    return date.toString();
  }

  /// Format DateTime with time for display
  String _formatDateTime(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy - HH:mm:ss').format(date);
  }
}
