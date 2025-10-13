import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/armor_themes.dart';
import 'theme_card.dart';

class ThemeOptionsGrid extends StatelessWidget {
  final Function(BuildContext, ArmorThemeMode) onThemeUpdate;

  const ThemeOptionsGrid({Key? key, required this.onThemeUpdate})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          Row(
            children: ArmorThemeMode.values.asMap().entries.map((entry) {
              final index = entry.key;
              final mode = entry.value;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < ArmorThemeMode.values.length - 1 ? 8 : 0,
                  ),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    curve: Curves.easeOutCubic,
                    height: 60,
                    child: ThemeCard(
                      mode: mode,
                      isSelected: themeProvider.currentThemeMode == mode,
                      onTap: () => onThemeUpdate(context, mode),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
