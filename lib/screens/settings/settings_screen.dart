import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/armor_themes.dart';
import 'components/section_header.dart';
import 'components/theme_selector.dart';
import 'components/coming_soon_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
              const SectionHeader(
                title: 'Appearance',
                icon: Icons.palette_rounded,
              ),
              const SizedBox(height: 16),
              ThemeSelector(onThemeUpdate: _updateTheme),

              const SizedBox(height: 32),

              // Coming Soon Section
              const SectionHeader(
                title: 'More Settings',
                icon: Icons.construction_rounded,
              ),
              const SizedBox(height: 16),
              const ComingSoonCard(),
            ],
          ),
        ),
      ),
    );
  }
}
