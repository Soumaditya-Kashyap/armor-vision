import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../providers/theme_provider.dart';
import '../../utils/armor_themes.dart';
import '../../models/app_settings.dart';
import '../../models/export_models.dart';
import '../../services/database_service.dart';
import '../../services/export_password_service.dart';
import '../../services/encryption_service.dart';
import 'components/section_header.dart';
import 'components/theme_selector.dart';
import 'components/coming_soon_card.dart';
import 'components/secure_export_card.dart';
import 'components/backup_restore_card.dart';
import '../../widgets/dialogs/export_dialog.dart';
import '../../widgets/dialogs/export_progress_dialog.dart';
import '../../widgets/dialogs/export_success_dialog.dart';
import '../../widgets/dialogs/set_default_password_dialog.dart';
import '../backup/backup_restore_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ExportPasswordService _exportService = ExportPasswordService();
  final EncryptionService _encryptionService = EncryptionService();

  AppSettings? _settings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load app settings
  Future<void> _loadSettings() async {
    try {
      final settings = await _databaseService.getAppSettings();
      if (mounted) {
        setState(() => _settings = settings);
      }
    } catch (e) {
      debugPrint('❌ Failed to load settings: $e');
    }
  }

  /// Open export dialog
  Future<void> _openExportDialog() async {
    final config = await showDialog<ExportConfig>(
      context: context,
      builder: (context) => const ExportDialog(),
    );

    if (config != null && mounted) {
      await _executeExport(config);
    }
  }

  /// Execute the export operation
  Future<void> _executeExport(ExportConfig config) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    // Show progress dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ExportProgressDialog(
          currentStep: 1,
          totalSteps: 4,
          statusText: 'Preparing export...',
        ),
      );
    }

    try {
      // Update progress: Generating file
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ExportProgressDialog(
            currentStep: 2,
            totalSteps: 4,
            statusText: 'Generating file...',
          ),
        );
      }

      // Get password (either from config or default)
      String password = config.password;
      if (config.useDefaultPassword &&
          _settings?.defaultExportPassword != null) {
        // Decrypt the stored default password
        password = _encryptionService.decrypt(
          _settings!.defaultExportPassword!,
        );
      }

      // Create export config with actual password
      final exportConfig = config.copyWith(password: password);

      // Update progress: Encrypting
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ExportProgressDialog(
            currentStep: 3,
            totalSteps: 4,
            statusText: 'Encrypting file...',
          ),
        );
      }

      // Perform export
      final result = await _exportService.exportPasswords(exportConfig);

      // Update progress: Saving
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ExportProgressDialog(
            currentStep: 4,
            totalSteps: 4,
            statusText: 'Saving file...',
          ),
        );
      }

      // Small delay for UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Close progress dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Handle result
      if (result.isSuccess && mounted) {
        // Update last export date
        final now = DateTime.now();
        final updatedSettings =
            _settings?.copyWith(lastExportDate: now) ??
            AppSettings(createdAt: now, updatedAt: now, lastExportDate: now);

        await _databaseService.saveAppSettings(updatedSettings);
        await _loadSettings();

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => ExportSuccessDialog(
            filePath: result.filePath ?? 'Unknown',
            fileSize: result.fileSizeFormatted,
            entriesExported: result.entriesExported,
          ),
        );
      } else if (mounted) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Export failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close any open dialogs
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Open set default password dialog
  Future<void> _openSetDefaultPasswordDialog() async {
    // Decrypt current password if exists
    String? currentPassword;
    if (_settings?.defaultExportPassword != null) {
      try {
        currentPassword = _encryptionService.decrypt(
          _settings!.defaultExportPassword!,
        );
      } catch (e) {
        debugPrint('❌ Failed to decrypt current password: $e');
      }
    }

    final password = await showDialog<String>(
      context: context,
      builder: (context) =>
          SetDefaultPasswordDialog(currentPassword: currentPassword),
    );

    if (password != null) {
      await _saveDefaultPassword(password);
    }
  }

  /// Save default password to settings
  Future<void> _saveDefaultPassword(String password) async {
    try {
      // Encrypt password before storing
      final encryptedPassword = _encryptionService.encrypt(password);

      // Update settings
      final now = DateTime.now();
      final updatedSettings =
          _settings?.copyWith(defaultExportPassword: encryptedPassword) ??
          AppSettings(
            createdAt: now,
            updatedAt: now,
            defaultExportPassword: encryptedPassword,
          );

      await _databaseService.saveAppSettings(updatedSettings);
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Default password saved successfully! 🔐'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Open Backup & Restore screen
  void _openBackupRestore() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const BackupRestoreScreen()),
    );
  }

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

              // Secure Export Section
              const SectionHeader(
                title: 'Secure Export',
                icon: Iconsax.document_download,
              ),
              const SizedBox(height: 16),
              SecureExportCard(
                lastExportDate: _settings?.lastExportDate,
                onExportNow: _openExportDialog,
                onSetDefaultPassword: _openSetDefaultPasswordDialog,
                hasDefaultPassword: _settings?.defaultExportPassword != null,
              ),

              const SizedBox(height: 32),

              // Backup & Restore Section
              const SectionHeader(
                title: 'Backup & Restore',
                icon: Iconsax.shield_tick,
              ),
              const SizedBox(height: 16),
              BackupRestoreCard(
                lastBackupDate: _settings?.lastBackupAt,
                onOpenBackupRestore: _openBackupRestore,
              ),

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
