import 'package:flutter/material.dart';
import '../../../models/password_entry.dart';
import '../../../utils/constants.dart';

class EntryHeader extends StatelessWidget {
  final PasswordEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onClose;

  const EntryHeader({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // Entry Icon/Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppHelpers.getEntryColor(entry.color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: AppHelpers.getEntryColor(entry.color),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Title and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.description != null && entry.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entry.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Button
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(44, 44),
                ),
                tooltip: 'Edit Entry',
              ),
              const SizedBox(width: 8),

              // Close Button
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
                  foregroundColor: colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.all(12),
                  minimumSize: const Size(44, 44),
                ),
                tooltip: 'Close',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
