import 'package:flutter/material.dart';

class CategorySelectionHeader extends StatelessWidget {
  final bool isMultiSelectMode;
  final VoidCallback onClose;

  const CategorySelectionHeader({
    super.key,
    required this.isMultiSelectMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final headerPadding = isLandscape ? 12.0 : 20.0;
    final iconSize = isLandscape ? 20.0 : 24.0;
    final borderRadius = isLandscape ? 16.0 : 24.0;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(headerPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isLandscape ? 6 : 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isLandscape ? 8 : 12),
            ),
            child: Icon(
              Icons.category_rounded,
              color: colorScheme.primary,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Category',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: isLandscape ? 16 : 18,
                  ),
                ),
                if (!isLandscape) ...[
                  const SizedBox(height: 2),
                  Text(
                    isMultiSelectMode
                        ? 'Tap to toggle, long press started multi-select'
                        : 'Tap to select, long press for multi-select',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurface.withOpacity(0.7),
              size: isLandscape ? 18 : 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.all(isLandscape ? 6 : 8),
              minimumSize: Size.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
