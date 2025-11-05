import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/password_entry.dart';
import '../../../widgets/password_entry_card.dart';

class EntriesList extends StatelessWidget {
  final List<PasswordEntry> entries;
  final bool isEmptyState;
  final String? emptyStateTitle;
  final String? emptyStateSubtitle;
  final IconData? emptyStateIcon;
  final Function(PasswordEntry) onEntryTap;
  final Function(PasswordEntry) onEntryLongPress;
  final Function(PasswordEntry) onFavoriteToggle;
  final Set<String> selectedEntryIds;
  final bool isSelectionMode;
  final bool showDateHeaders;
  final String sortOption;

  const EntriesList({
    super.key,
    required this.entries,
    required this.onEntryTap,
    required this.onEntryLongPress,
    required this.onFavoriteToggle,
    required this.selectedEntryIds,
    required this.isSelectionMode,
    this.isEmptyState = false,
    this.emptyStateTitle,
    this.emptyStateSubtitle,
    this.emptyStateIcon,
    this.showDateHeaders = false,
    this.sortOption = 'updated',
  });

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate == today) {
      return 'Today';
    } else if (entryDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(date); // Format: 05/11/2025
    }
  }

  List<Widget> _buildGroupedEntries(BuildContext context) {
    if (entries.isEmpty) return [];

    final widgets = <Widget>[];
    String? currentDateLabel;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isSelected = selectedEntryIds.contains(entry.id);

      // Get the appropriate date based on sort option
      final entryDate = sortOption == 'created'
          ? entry.createdAt
          : entry.updatedAt;
      final dateLabel = _getDateLabel(entryDate);

      // Add date header if it's a new date group
      if (dateLabel != currentDateLabel) {
        currentDateLabel = dateLabel;
        widgets.add(_buildDateHeader(context, dateLabel));
      }

      // Add the entry card
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PasswordEntryCard(
            entry: entry,
            isListView: true,
            isSelected: isSelected,
            isSelectionMode: isSelectionMode,
            onTap: () => onEntryTap(entry),
            onLongPress: () => onEntryLongPress(entry),
            onFavoriteToggle: () => onFavoriteToggle(entry),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildDateHeader(BuildContext context, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.5),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _buildEmptyState(context);
    }

    if (showDateHeaders && sortOption != 'alphabetical') {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: _buildGroupedEntries(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isSelected = selectedEntryIds.contains(entry.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PasswordEntryCard(
            entry: entry,
            isListView: true,
            isSelected: isSelected,
            isSelectionMode: isSelectionMode,
            onTap: () => onEntryTap(entry),
            onLongPress: () => onEntryLongPress(entry),
            onFavoriteToggle: () => onFavoriteToggle(entry),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  emptyStateIcon ?? Icons.lock_outline_rounded,
                  size: 56,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                emptyStateTitle ?? 'No Entries Yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                emptyStateSubtitle ??
                    'Your vault is empty. Tap the "Add Entry" button below to create your first password entry.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
