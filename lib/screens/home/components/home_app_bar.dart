import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  final int totalEntries;
  final VoidCallback onSettingsTap;
  final VoidCallback onViewModeTap;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback? onDeleteTap;

  const HomeAppBar({
    super.key,
    required this.totalEntries,
    required this.onSettingsTap,
    required this.onViewModeTap,
    this.isSelectionMode = false,
    this.selectedCount = 0,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Armor',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$totalEntries entries',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Animated Delete Button - Slides in from right
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(1.0, 0.0), // Start from right
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: isSelectionMode
                  ? Padding(
                      key: const ValueKey('delete_button'),
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: InkWell(
                          onTap: selectedCount > 0 ? onDeleteTap : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Colors.white.withOpacity(
                                    selectedCount > 0 ? 1.0 : 0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Delete ($selectedCount)',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Colors.white.withOpacity(
                                      selectedCount > 0 ? 1.0 : 0.5,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),

          // Settings and View Mode buttons
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onViewModeTap,
                  icon: const Icon(Icons.view_module_rounded, size: 18),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: const EdgeInsets.all(4),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: colorScheme.outline.withOpacity(0.3),
                ),
                IconButton(
                  onPressed: onSettingsTap,
                  icon: const Icon(Icons.settings_rounded, size: 18),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
