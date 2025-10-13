import 'package:flutter/material.dart';
import '../../../utils/armor_themes.dart';

class CurrentThemeDisplay extends StatelessWidget {
  final ArmorThemeMode currentTheme;

  const CurrentThemeDisplay({Key? key, required this.currentTheme})
    : super(key: key);

  String _getThemeDisplayName(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return 'Light';
      case ArmorThemeMode.dark:
        return 'Dark';
      case ArmorThemeMode.system:
        return 'System';
      case ArmorThemeMode.armor:
        return 'Special';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ArmorThemes.getThemePreviewColor(currentTheme);
    final backgroundColor = ArmorThemes.getThemeBackgroundColor(currentTheme);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              ArmorThemes.getThemeIcon(currentTheme),
              color: themeColor,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getThemeDisplayName(currentTheme),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: currentTheme == ArmorThemeMode.light
                        ? Colors.black87
                        : Colors.white,
                  ),
                ),
                Text(
                  ArmorThemes.getThemeDescription(currentTheme),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: (currentTheme == ArmorThemeMode.light
                        ? Colors.black54
                        : Colors.white70),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: themeColor, size: 20),
        ],
      ),
    );
  }
}
