import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/password_entry.dart';

class FieldCard extends StatelessWidget {
  final CustomField field;
  final bool shouldHideValue;

  const FieldCard({
    super.key,
    required this.field,
    required this.shouldHideValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Label with Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getFieldTypeColor(field.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getFieldTypeIcon(field.type),
                    size: 16,
                    color: _getFieldTypeColor(field.type),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    field.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (field.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Required',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Field Value
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shouldHideValue
                          ? '••••••••'
                          : (field.value.isEmpty ? 'No value' : field.value),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: field.value.isEmpty
                            ? colorScheme.onSurface.withOpacity(0.5)
                            : colorScheme.onSurface,
                        fontFamily: shouldHideValue ? 'monospace' : null,
                      ),
                    ),
                  ),

                  if (field.value.isNotEmpty) ...[
                    const SizedBox(width: 12),

                    // Copy Button
                    IconButton(
                      onPressed: () => _copyFieldValue(context, field),
                      icon: const Icon(Icons.copy_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                      tooltip: 'Copy',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFieldTypeColor(FieldType type) {
    switch (type) {
      case FieldType.password:
        return Colors.red;
      case FieldType.email:
        return Colors.blue;
      case FieldType.username:
        return Colors.green;
      case FieldType.url:
        return Colors.purple;
      case FieldType.text:
      default:
        return Colors.grey;
    }
  }

  IconData _getFieldTypeIcon(FieldType type) {
    switch (type) {
      case FieldType.password:
        return Icons.lock_rounded;
      case FieldType.email:
        return Icons.email_rounded;
      case FieldType.username:
        return Icons.person_rounded;
      case FieldType.url:
        return Icons.link_rounded;
      case FieldType.text:
      default:
        return Icons.text_fields_rounded;
    }
  }

  void _copyFieldValue(BuildContext context, CustomField field) {
    Clipboard.setData(ClipboardData(text: field.value));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${field.label} copied to clipboard',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
