import 'package:flutter/material.dart';

class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final String? sortOption;
  final ValueChanged<String>? onSortChanged;
  final bool showSortButton;

  const HomeSearchBar({
    super.key,
    required this.onSearchChanged,
    this.sortOption,
    this.onSortChanged,
    this.showSortButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search your vault...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (showSortButton && onSortChanged != null)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.sort_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              tooltip: 'Sort by',
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'updated',
                  child: Row(
                    children: [
                      Icon(
                        sortOption == 'updated'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: sortOption == 'updated'
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Last Updated',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: sortOption == 'updated'
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: sortOption == 'updated'
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mostUsed',
                  child: Row(
                    children: [
                      Icon(
                        sortOption == 'mostUsed'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: sortOption == 'mostUsed'
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Most Used',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: sortOption == 'mostUsed'
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: sortOption == 'mostUsed'
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'alphabetical',
                  child: Row(
                    children: [
                      Icon(
                        sortOption == 'alphabetical'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: sortOption == 'alphabetical'
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Alphabetical',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: sortOption == 'alphabetical'
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: sortOption == 'alphabetical'
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: onSortChanged,
            ),
        ],
      ),
    );
  }
}
