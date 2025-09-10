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
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 350),
                  opacity: _isThemeExpanded ? 1.0 : 0.0,
                  child: _isThemeExpanded
                      ? AnimatedSlide(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          offset: _isThemeExpanded
                              ? Offset.zero
                              : const Offset(0, -0.1),
                          child: _buildThemeOptions(
                            colorScheme,
                            context,
                            themeProvider,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
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
                  ArmorThemes.getThemeDisplayName(currentTheme),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextColorForTheme(currentTheme),
                  ),
                ),
                Text(
                  ArmorThemes.getThemeDescription(currentTheme),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getSubtextColorForTheme(currentTheme),
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.5,
            children: ArmorThemeMode.values.asMap().entries.map((entry) {
              final index = entry.key;
              final mode = entry.value;

              return AnimatedOpacity(
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutCubic,
                opacity: _isThemeExpanded ? 1.0 : 0.0,
                child: AnimatedScale(
                  duration: Duration(milliseconds: 350 + (index * 75)),
                  curve: Curves.easeOutBack,
                  scale: _isThemeExpanded ? 1.0 : 0.8,
                  child: _buildCompactThemeCard(
                    mode,
                    colorScheme,
                    context,
                    themeProvider,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactThemeCard(
    ArmorThemeMode mode,
    ColorScheme colorScheme,
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    final isSelected = themeProvider.currentThemeMode == mode;
    final themeColor = ArmorThemes.getThemePreviewColor(mode);
    final backgroundColor = ArmorThemes.getThemeBackgroundColor(mode);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _updateTheme(context, mode),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? themeColor
                        : colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: themeColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          ArmorThemes.getThemeIcon(mode),
                          color: themeColor,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ArmorThemes.getThemeDisplayName(mode),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _getTextColorForTheme(mode),
                                fontSize: 12,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_rounded, color: themeColor, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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

  Color _getTextColorForTheme(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return Colors.grey.shade800; // Dark gray for better contrast on light
      case ArmorThemeMode.system:
        return Colors.grey.shade700; // Medium gray for system
      case ArmorThemeMode.dark:
        return Colors.white;
      case ArmorThemeMode.armor:
        return Colors.white;
    }
  }

  Color _getSubtextColorForTheme(ArmorThemeMode mode) {
    switch (mode) {
      case ArmorThemeMode.light:
        return Colors.grey.shade600; // Medium gray for subtext on light
      case ArmorThemeMode.system:
        return Colors.grey.shade500; // Lighter gray for system subtext
      case ArmorThemeMode.dark:
        return Colors.white70;
      case ArmorThemeMode.armor:
        return Colors.white70;
    }
  }
}
