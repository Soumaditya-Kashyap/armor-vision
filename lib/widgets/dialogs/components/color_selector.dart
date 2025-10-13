import 'package:flutter/material.dart';
import '../../../models/password_entry.dart';
import '../../../utils/constants.dart';

class ColorSelector extends StatelessWidget {
  final EntryColor selectedColor;
  final Function(EntryColor) onColorSelected;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EntryColor.values.map((color) {
            final isSelected = color == selectedColor;
            return _buildColorOption(color, isSelected, theme);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorOption(EntryColor color, bool isSelected, ThemeData theme) {
    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppHelpers.getEntryColor(color),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppHelpers.getEntryColor(color).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                color: _getContrastColor(AppHelpers.getEntryColor(color)),
                size: 20,
              )
            : null,
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use black or white text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
