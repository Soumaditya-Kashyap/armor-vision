import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/armor_themes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isThemeExpanded = false;

  Future<void> _updateTheme(
    BuildContext context,
    ArmorThemeMode newTheme,
  ) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    try {
      await themeProvider.setThemeMode(newTheme);

      // Show feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Theme changed to ${ArmorThemes.getThemeDisplayName(newTheme)}! ✨',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update theme: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 300),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              _buildSectionHeader(
                'Appearance',
                Icons.palette_rounded,
                colorScheme,
                context,
              ),
              const SizedBox(height: 16),
              _buildThemeSelector(colorScheme, context),

              const SizedBox(height: 32),

              // Coming Soon Section
              _buildSectionHeader(
                'More Settings',
                Icons.construction_rounded,
                colorScheme,
                context,
              ),
              const SizedBox(height: 16),
              _buildComingSoonCard(colorScheme, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(ColorScheme colorScheme, BuildContext context) {
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
                      _buildCurrentThemeDisplay(
                        themeProvider.currentThemeMode,
                        colorScheme,
                        context,
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
                        child: _buildThemeOptions(
                          colorScheme,
                          context,
                          themeProvider,
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

  Widget _buildCurrentThemeDisplay(
    ArmorThemeMode currentTheme,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
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

  Widget _buildThemeOptions(
    ColorScheme colorScheme,
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isThemeExpanded
                ? Row(
                    key: const ValueKey('theme_row'),
                    children: ArmorThemeMode.values.asMap().entries.map((
                      entry,
                    ) {
                      final index = entry.key;
                      final mode = entry.value;

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index < ArmorThemeMode.values.length - 1
                                ? 8
                                : 0,
                          ),
                          child: AnimatedContainer(
                            duration: Duration(
                              milliseconds: 200 + (index * 50),
                            ),
                            curve: Curves.easeOutCubic,
                            height: 60, // Match the card height
                            child: _buildSquareThemeCard(
                              mode,
                              colorScheme,
                              context,
                              themeProvider,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareThemeCard(
    ArmorThemeMode mode,
    ColorScheme colorScheme,
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.currentThemeMode == mode;
    final themeColor = ArmorThemes.getThemePreviewColor(mode);
    // Make Light theme use dark background too
    final backgroundColor = mode == ArmorThemeMode.light
        ? const Color(0xFF2A2A2A) // Dark background for Light theme
        : ArmorThemes.getThemeBackgroundColor(mode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _updateTheme(context, mode),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 60, // Compact height
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
              // Properly sized icon - centered
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

  String _getThemeDisplayName(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return 'Light';
      case ArmorThemeMode.dark:
        return 'Dark';
      case ArmorThemeMode.system:
        return 'System';
      case ArmorThemeMode.armor:
        return 'Special'; // Changed from "Armor Aurora" to "Special"
    }
  }

  Widget _buildComingSoonCard(ColorScheme colorScheme, BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.construction_rounded,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'More Settings Coming Soon',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Security settings, backup options, and more customization features will be available in future updates.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
