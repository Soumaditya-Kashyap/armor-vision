import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../utils/constants.dart';

class PasswordEntryCard extends StatelessWidget {
  final PasswordEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isListView;

  const PasswordEntryCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onFavoriteToggle,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isListView) {
      return _buildListCard(theme, colorScheme);
    } else {
      return _buildGridCard(theme, colorScheme);
    }
  }

  Widget _buildGridCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and favorite
              Row(
                children: [
                  // Color indicator
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppHelpers.getEntryColor(entry.color),
                      borderRadius: BorderRadius.circular(2),
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
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: entry.isFavorite
                            ? Colors.red
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
                    color: AppHelpers.getEntryColor(
                      entry.color,
                    ).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.category!.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppHelpers.getEntryColor(entry.color),
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
              const Spacer(),
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
    );
  }

  Widget _buildListCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Color indicator and icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppHelpers.getEntryColor(
                    entry.color,
                  ).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: AppHelpers.getEntryColor(entry.color),
                  size: 24,
                ),
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
                        if (entry.isFavorite) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: Colors.red,
                          ),
                        ],
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
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppHelpers.getEntryColor(entry.color),
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
                              color: colorScheme.onSurface.withOpacity(0.5),
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
              InkWell(
                onTap: onFavoriteToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    entry.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 20,
                    color: entry.isFavorite
                        ? Colors.red
                        : colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
