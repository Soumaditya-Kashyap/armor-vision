import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/armor_themes.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred app theme',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: ArmorThemeMode.values.map((mode) {
              return _buildThemeCard(mode, colorScheme, context);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    ArmorThemeMode mode,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isSelected = themeProvider.currentThemeMode == mode;
        final themeColor = ArmorThemes.getThemePreviewColor(mode);
        final backgroundColor = ArmorThemes.getThemeBackgroundColor(mode);

        return GestureDetector(
          onTap: () => _updateTheme(context, mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? themeColor
                    : colorScheme.outline.withOpacity(0.3),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: themeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Theme Icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      ArmorThemes.getThemeIcon(mode),
                      color: themeColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Theme Name
                  Text(
                    ArmorThemes.getThemeDisplayName(mode),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: mode == ArmorThemeMode.light
                          ? Colors.black87
                          : Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  // Theme Description
                  Text(
                    ArmorThemes.getThemeDescription(mode),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: (mode == ArmorThemeMode.light
                          ? Colors.black54
                          : Colors.white70),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Selection Indicator
                  if (isSelected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                ],
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
}
