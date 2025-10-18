import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CategoryActionButtons extends StatelessWidget {
  final bool isMultiSelectMode;
  final int selectedCount;
  final bool hasSelection;
  final VoidCallback onContinue;
  final VoidCallback onSingleSelectMode;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;

  const CategoryActionButtons({
    super.key,
    required this.isMultiSelectMode,
    required this.selectedCount,
    required this.hasSelection,
    required this.onContinue,
    required this.onSingleSelectMode,
    required this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonPadding = isLandscape ? 12.0 : 20.0;
    final buttonHeight = isLandscape ? 10.0 : 14.0;
    final borderRadius = isLandscape ? 16.0 : 24.0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(buttonPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: (isLandscape || screenWidth < 400)
          ? _buildStackedButtons(context, buttonHeight, isLandscape)
          : _buildRowButtons(context, buttonHeight),
    );
  }

  Widget _buildStackedButtons(
    BuildContext context,
    double buttonHeight,
    bool isLandscape,
  ) {
    return Column(
      children: [
        // Multi-select mode indicator
        if (isMultiSelectMode) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Multi-select mode: $selectedCount selected',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: hasSelection ? onContinue : null,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isMultiSelectMode
                  ? 'Continue with $selectedCount categories'
                  : 'Continue',
            ),
          ),
        ),
        SizedBox(height: isLandscape ? 8 : 10),
        Row(
          children: [
            if (isMultiSelectMode) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSingleSelectMode,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Iconsax.arrow_swap_horizontal, size: 18),
                  label: const Text('Single'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: isMultiSelectMode && hasSelection
                  ? OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: buttonHeight),
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Delete ($selectedCount)'),
                    )
                  : OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: buttonHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRowButtons(BuildContext context, double buttonHeight) {
    return Row(
      children: [
        if (isMultiSelectMode) ...[
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSingleSelectMode,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Iconsax.arrow_swap_horizontal, size: 18),
              label: const Text('Single'),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: isMultiSelectMode && hasSelection
              ? OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: buttonHeight),
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Delete ($selectedCount)'),
                )
              : OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: buttonHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: hasSelection ? onContinue : null,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isMultiSelectMode ? 'Continue ($selectedCount)' : 'Continue',
            ),
          ),
        ),
      ],
    );
  }
}
