import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/armor_themes.dart';
import 'current_theme_display.dart';
import 'theme_options_grid.dart';

class ThemeSelector extends StatefulWidget {
  final Function(BuildContext, ArmorThemeMode) onThemeUpdate;

  const ThemeSelector({Key? key, required this.onThemeUpdate})
    : super(key: key);

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  bool _isThemeExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with current theme display
              InkWell(
                onTap: () {
                  setState(() {
                    _isThemeExpanded = !_isThemeExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Theme',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                            turns: _isThemeExpanded ? 0.5 : 0,
                            child: Icon(
                              Icons.expand_more_rounded,
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose your preferred app theme',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Current theme display
                      CurrentThemeDisplay(
                        currentTheme: themeProvider.currentThemeMode,
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable theme options
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                child: _isThemeExpanded
                    ? AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: 1.0,
                        child: ThemeOptionsGrid(
                          onThemeUpdate: widget.onThemeUpdate,
                        ),
                      )
                    : const SizedBox(height: 0, width: double.infinity),
              ),
            ],
          ),
        );
      },
    );
  }
}
