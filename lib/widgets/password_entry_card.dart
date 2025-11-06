import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/password_entry.dart';
import '../utils/constants.dart';
import '../utils/icon_helper.dart';

class PasswordEntryCard extends StatelessWidget {
  final PasswordEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavoriteToggle;
  final bool isListView;
  final bool isSelected;
  final bool isSelectionMode;

  const PasswordEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onLongPress,
    this.onFavoriteToggle,
    this.isListView = false,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  /// Get the icon for this entry based on its category
  IconData _getEntryIcon() {
    // If entry has a category, try to get the actual category icon from database
    if (entry.category != null && entry.category!.isNotEmpty) {
      try {
        // Access the categories box directly (synchronous)
        final categoriesBox = Hive.box<Category>('categories');

        // Find the matching category by ID (not name!)
        final category = categoriesBox.values.firstWhere(
          (cat) => cat.id == entry.category,
          orElse: () => categoriesBox.values.first, // fallback
        );

        // Use the category's iconName to get the actual icon
        return IconHelper.getIconData(category.iconName);
      } catch (e) {
        // If database lookup fails, use name-based matching as fallback
        return AppHelpers.getCategoryIcon(entry.category);
      }
    }

    // Fallback to the smart detection method
    return AppHelpers.getEntryIcon(entry);
  }

  /// Get the color for this entry based on its category
  Color _getEntryColor(BuildContext context) {
    // If entry has a category, try to get the actual category color from database
    if (entry.category != null && entry.category!.isNotEmpty) {
      try {
        // Access the categories box directly (synchronous)
        final categoriesBox = Hive.box<Category>('categories');

        // Find the matching category by ID (not name!)
        final category = categoriesBox.values.firstWhere(
          (cat) => cat.id == entry.category,
          orElse: () => categoriesBox.values.first, // fallback
        );

        // Convert EntryColor enum to actual Color
        return _convertEntryColor(category.color);
      } catch (e) {
        // If database lookup fails, use default blue
        return Theme.of(context).colorScheme.primary;
      }
    }

    // Fallback to default blue
    return Theme.of(context).colorScheme.primary;
  }

  /// Convert EntryColor enum to Material Color with proper shades
  Color _convertEntryColor(EntryColor entryColor) {
    switch (entryColor) {
      case EntryColor.red:
        return Colors.red.shade700; // Deep red for Gmail
      case EntryColor.green:
        return Colors.green.shade700; // Deep green for Work
      case EntryColor.teal:
        return Colors.teal.shade600; // Teal green for Banking
      case EntryColor.blue:
        return Colors.blue.shade700; // Deep blue for General
      case EntryColor.purple:
        return Colors.purple.shade600; // Purple for Social/Entertainment
      case EntryColor.orange:
        return Colors.orange.shade700; // Orange
      case EntryColor.amber:
        return Colors.amber.shade700; // Amber/Yellow for Shopping
      case EntryColor.pink:
        return Colors.pink.shade600; // Pink
      case EntryColor.indigo:
        return Colors.indigo.shade700; // Indigo
      case EntryColor.gray:
        return Colors.grey.shade600; // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entryColor = _getEntryColor(context);

    if (isListView) {
      return _buildListCard(theme, colorScheme, entryColor);
    } else {
      return _buildGridCard(theme, colorScheme, entryColor);
    }
  }

  Widget _buildGridCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Color entryColor,
  ) {
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        side: entry.isFavorite
            ? BorderSide(color: entryColor, width: 2.5)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                border: isSelected
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with icon, title and favorite
                    Row(
                      children: [
                        // Category icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: entryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getEntryIcon(),
                            color: entryColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Color indicator - thicker when favorite
                        Container(
                          width: entry.isFavorite ? 5 : 3,
                          height: entry.isFavorite ? 24 : 20,
                          decoration: BoxDecoration(
                            color: entryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.displayTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Favorite button
                        InkWell(
                          onTap: onFavoriteToggle,
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              entry.isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 20,
                              color: entry.isFavorite
                                  ? Colors.amber
                                  : colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Description (only if short)
                    if (entry.description != null &&
                        entry.description!.isNotEmpty) ...[
                      Text(
                        entry.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Field count
                    Row(
                      children: [
                        Icon(
                          Icons.key_rounded,
                          size: 14,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.customFields.length} ${entry.customFields.length == 1 ? 'field' : 'fields'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Category badge (if available)
                    if (entry.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: entryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.category!.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: entryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],

                    // Bottom section - last modified
                    const SizedBox(height: 6),
                    Text(
                      'Modified ${AppHelpers.formatDate(entry.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Selection checkbox overlay
          if (isSelectionMode)
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedScale(
                scale: isSelectionMode ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Color entryColor,
  ) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        side: entry.isFavorite
            ? BorderSide(color: entryColor, width: 2.5)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
                border: isSelected
                    ? Border.all(color: colorScheme.primary, width: 2)
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Dynamic icon based on category
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: entryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_getEntryIcon(), color: entryColor, size: 24),
                    ),

                    const SizedBox(width: 16),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and favorite
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.displayTitle,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Description or field info
                          Text(
                            entry.description?.isNotEmpty == true
                                ? entry.description!
                                : '${entry.customFields.length} ${entry.customFields.length == 1 ? 'field' : 'fields'}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Category and date
                          Row(
                            children: [
                              if (entry.category != null) ...[
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppHelpers.getEntryColor(
                                        entry.color,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      entry.category!.toUpperCase(),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: AppHelpers.getEntryColor(
                                              entry.color,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  AppHelpers.formatDate(entry.updatedAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action button
                    if (!isSelectionMode)
                      InkWell(
                        onTap: onFavoriteToggle,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            entry.isFavorite
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 20,
                            color: entry.isFavorite
                                ? Colors.amber
                                : colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Selection checkbox overlay
          if (isSelectionMode)
            Positioned(
              top: 12,
              right: 12,
              child: AnimatedScale(
                scale: isSelectionMode ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
