import 'package:flutter/material.dart';
import '../../../models/password_entry.dart';
import '../../custom_field_widget.dart';

class CustomFieldsSection extends StatelessWidget {
  final List<CustomField> customFields;
  final bool isEditMode;
  final bool isPasswordVisible;
  final Function(CustomField) onFieldChanged;
  final Function(int) onRemoveField;
  final VoidCallback onToggleEditMode;
  final VoidCallback onAddField;

  const CustomFieldsSection({
    super.key,
    required this.customFields,
    required this.isEditMode,
    required this.isPasswordVisible,
    required this.onFieldChanged,
    required this.onRemoveField,
    required this.onToggleEditMode,
    required this.onAddField,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Edit/Done button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Custom Fields',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: onToggleEditMode,
              icon: Icon(
                isEditMode ? Icons.check_circle : Icons.edit_rounded,
                size: 18,
              ),
              label: Text(isEditMode ? 'Done' : 'Edit'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Fields list or empty state
        if (customFields.isEmpty)
          _buildEmptyState(context)
        else
          ...customFields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < customFields.length - 1 ? 12 : 0,
              ),
              child: CustomFieldWidget(
                key: ValueKey(field.label),
                field: field,
                isPasswordVisible: isPasswordVisible,
                onFieldChanged: onFieldChanged,
                onRemoveField: () => onRemoveField(index),
              ),
            );
          }).toList(),

        // Add field button (only in edit mode)
        if (isEditMode) ...[
          const SizedBox(height: 12),
          _buildAddFieldButton(context),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.library_add_outlined,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No Custom Fields',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isEditMode
                ? 'Click "Add Field" to create custom fields'
                : 'Click "Edit" to add custom fields',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddFieldButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: onAddField,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add Field'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
      ),
    );
  }
}
