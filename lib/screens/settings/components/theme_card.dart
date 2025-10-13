import 'package:flutter/material.dart';
import '../../../utils/armor_themes.dart';

class ThemeCard extends StatelessWidget {
  final ArmorThemeMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeCard({
    Key? key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeColor = ArmorThemes.getThemePreviewColor(mode);
    // Make Light theme use dark background too
    final backgroundColor = mode == ArmorThemeMode.light
        ? const Color(0xFF2A2A2A) // Dark background for Light theme
        : ArmorThemes.getThemeBackgroundColor(mode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? themeColor
                  : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  ArmorThemes.getThemeIcon(mode),
                  color: themeColor,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
