import 'package:flutter/material.dart';
import '../../../models/password_entry.dart';
import 'field_card.dart';

class FieldsListSection extends StatelessWidget {
  final PasswordEntry entry;
  final bool allFieldsVisible;
  final VoidCallback onToggleVisibility;

  const FieldsListSection({
    super.key,
    required this.entry,
    required this.allFieldsVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (entry.customFields.isEmpty) {
      return _buildEmptyState(theme, colorScheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fields header with inline eye button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fields',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            IconButton(
              onPressed: onToggleVisibility,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  allFieldsVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  key: ValueKey(allFieldsVisible),
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary.withOpacity(0.1),
                foregroundColor: colorScheme.primary,
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(36, 36),
              ),
              tooltip: allFieldsVisible ? 'Hide All Fields' : 'Show All Fields',
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...entry.customFields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < this.entry.customFields.length - 1 ? 12 : 0,
            ),
            child: FieldCard(field: field, shouldHideValue: !allFieldsVisible),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No Fields',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'This entry doesn\'t have any custom fields',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
