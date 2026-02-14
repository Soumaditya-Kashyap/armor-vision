import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:iconsax/iconsax.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/backup_service.dart';
import '../../services/database_service.dart';
import '../settings/components/section_header.dart';

class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final BackupService _backupService = BackupService();
  final DatabaseService _databaseService = DatabaseService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<BackupFileInfo> _existingBackups = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _loadExistingBackups();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload backups when app resumes (becomes visible again)
    if (state == AppLifecycleState.resumed) {
      _loadExistingBackups();
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingBackups() async {
    debugPrint('🔄 Loading existing backups...');
    final backups = await _backupService.getExistingBackups();
    debugPrint('✅ Found ${backups.length} backup(s)');
    if (mounted) {
      setState(() => _existingBackups = backups);
    }
  }

  Future<void> _refreshBackups() async {
    setState(() => _isLoading = true);
    await _loadExistingBackups();
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${_existingBackups.length} backup(s)'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _createBackup() async {
    // Show master password dialog
    final password = await _showPasswordDialog(
      title: 'Create Backup',
      subtitle:
          'Enter a master password to encrypt your backup.\nYou will need this password to restore later.',
      confirmText: 'Create Backup',
      isCreating: true,
    );

    if (password == null || password.isEmpty) return;

    setState(() => _isLoading = true);

    // Show progress dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildProgressDialog('Creating backup...'),
      );
    }

    try {
      final result = await _backupService.createBackup(password);

      // Close progress dialog
      if (mounted) Navigator.of(context).pop();

      if (result.isSuccess && mounted) {
        // Update last backup date in settings
        await _updateLastBackupDate();

        // Wait a moment for file system to update, then reload backups list
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadExistingBackups();

        // Show success dialog with share option
        await _showBackupSuccessDialog(result);
      } else if (mounted) {
        _showErrorSnackBar(result.errorMessage ?? 'Failed to create backup');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showErrorSnackBar('Backup failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLastBackupDate() async {
    try {
      final settings = await _databaseService.getAppSettings();
      final now = DateTime.now();
      final updatedSettings = settings.copyWith(
        lastBackupAt: now,
        updatedAt: now,
      );
      await _databaseService.saveAppSettings(updatedSettings);
    } catch (e) {
      debugPrint('Failed to update last backup date: $e');
    }
  }

  Future<void> _restoreFromFile() async {
    try {
      // Request storage permissions
      PermissionStatus status;
      if (Platform.isAndroid) {
        // Try manageExternalStorage first (Android 11+)
        status = await Permission.manageExternalStorage.status;

        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }

        // Fallback to regular storage permission if needed
        if (!status.isGranted) {
          status = await Permission.storage.status;
          if (!status.isGranted) {
            status = await Permission.storage.request();
          }
        }
      } else if (Platform.isIOS) {
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }
      } else {
        status = PermissionStatus.granted;
      }

      if (status.isDenied) {
        _showErrorSnackBar(
          'Storage permission is required to access backup files',
        );
        return;
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, offer to open settings
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'Storage permission is permanently denied. Please enable it in app settings.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Get backup directory path
      final backupDir = await _backupService.getBackupDirectoryPath();

      // Force file system to refresh and sync
      if (backupDir != null) {
        final dir = Directory(backupDir);
        if (await dir.exists()) {
          // Force directory listing to refresh the cache
          await dir.list().toList();
          // Add small delay to ensure file system sync
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      debugPrint('📂 Opening file picker for backup restore...');

      // Pick .armor file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        initialDirectory: backupDir,
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      if (filePath == null) {
        _showErrorSnackBar('Could not access the selected file');
        return;
      }

      // Check if it's an .armor file
      if (!filePath.endsWith('.armor')) {
        _showErrorSnackBar('Please select a valid .armor backup file');
        return;
      }

      // Validate backup file
      final validation = await _backupService.validateBackup(filePath);
      if (!validation.isValid) {
        _showErrorSnackBar(validation.errorMessage ?? 'Invalid backup file');
        return;
      }

      // Show validation info and ask for password
      final shouldProceed = await _showRestoreConfirmDialog(
        validation,
        filePath,
      );
      if (shouldProceed != true) return;

      // Ask for master password
      final password = await _showPasswordDialog(
        title: 'Restore Backup',
        subtitle:
            'Enter the master password you used when creating this backup.',
        confirmText: 'Restore',
        isCreating: false,
      );

      if (password == null || password.isEmpty) return;

      // Ask about replace mode
      final replaceExisting = await _showReplaceConfirmDialog();
      if (replaceExisting == null) return;

      setState(() => _isLoading = true);

      // Show progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildProgressDialog('Restoring backup...'),
        );
      }

      final restoreResult = await _backupService.restoreBackup(
        filePath,
        password,
        replaceExisting: replaceExisting,
      );

      // Close progress dialog
      if (mounted) Navigator.of(context).pop();

      if (restoreResult.isSuccess && mounted) {
        await _showRestoreSuccessDialog(restoreResult);
      } else if (mounted) {
        _showErrorSnackBar(
          restoreResult.errorMessage ?? 'Failed to restore backup',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Restore failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreFromExisting(BackupFileInfo backup) async {
    // Validate backup file
    final validation = await _backupService.validateBackup(backup.filePath);
    if (!validation.isValid) {
      _showErrorSnackBar(validation.errorMessage ?? 'Invalid backup file');
      return;
    }

    // Show validation info and ask for password
    final shouldProceed = await _showRestoreConfirmDialog(
      validation,
      backup.filePath,
    );
    if (shouldProceed != true) return;

    // Ask for master password
    final password = await _showPasswordDialog(
      title: 'Restore Backup',
      subtitle: 'Enter the master password you used when creating this backup.',
      confirmText: 'Restore',
      isCreating: false,
    );

    if (password == null || password.isEmpty) return;

    // Ask about replace mode
    final replaceExisting = await _showReplaceConfirmDialog();
    if (replaceExisting == null) return;

    setState(() => _isLoading = true);

    // Show progress dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildProgressDialog('Restoring backup...'),
      );
    }

    try {
      final restoreResult = await _backupService.restoreBackup(
        backup.filePath,
        password,
        replaceExisting: replaceExisting,
      );

      // Close progress dialog
      if (mounted) Navigator.of(context).pop();

      if (restoreResult.isSuccess && mounted) {
        await _showRestoreSuccessDialog(restoreResult);
      } else if (mounted) {
        _showErrorSnackBar(
          restoreResult.errorMessage ?? 'Failed to restore backup',
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showErrorSnackBar('Restore failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _shareBackup(BackupFileInfo backup) async {
    final success = await _backupService.shareBackupFile(backup.filePath);
    if (!success && mounted) {
      _showErrorSnackBar('Failed to share backup file');
    }
  }

  Future<void> _deleteBackup(BackupFileInfo backup) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Are you sure you want to delete "${backup.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _backupService.deleteBackup(backup.filePath);
      if (success) {
        await _loadExistingBackups();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Backup deleted')));
        }
      } else {
        _showErrorSnackBar('Failed to delete backup');
      }
    }
  }

  Future<String?> _showPasswordDialog({
    required String title,
    required String subtitle,
    required String confirmText,
    required bool isCreating,
  }) async {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;
    bool obscureConfirm = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  isCreating ? Iconsax.lock : Iconsax.unlock,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Master Password',
                        prefixIcon: const Icon(Iconsax.key),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                          ),
                          onPressed: () {
                            setState(() => obscurePassword = !obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (isCreating && value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                    if (isCreating) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Iconsax.key),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Iconsax.eye : Iconsax.eye_slash,
                            ),
                            onPressed: () {
                              setState(() => obscureConfirm = !obscureConfirm);
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.error.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_rounded,
                              color: colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Remember this password! It cannot be recovered if lost.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(null),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(passwordController.text);
                  }
                },
                child: Text(confirmText),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool?> _showRestoreConfirmDialog(
    BackupValidationResult validation,
    String filePath,
  ) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Iconsax.document_download, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Backup Details'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Created', _formatDate(validation.createdAt)),
            const SizedBox(height: 8),
            _buildInfoRow('Entries', '${validation.entriesCount ?? 'Unknown'}'),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Categories',
              '${validation.categoriesCount ?? 'Unknown'}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Version', validation.backupVersion ?? 'Unknown'),
            const SizedBox(height: 16),
            Text(
              'Do you want to restore from this backup?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showReplaceConfirmDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.swap_horiz_rounded, color: colorScheme.primary),
            const SizedBox(width: 12),
            const Text('Restore Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How would you like to restore?',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            _buildRestoreOption(
              context,
              icon: Icons.merge_rounded,
              title: 'Merge',
              description: 'Add restored entries alongside existing data',
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 12),
            _buildRestoreOption(
              context,
              icon: Icons.delete_sweep_rounded,
              title: 'Replace',
              description: 'Delete existing data and restore from backup',
              isDestructive: true,
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = isDestructive ? colorScheme.error : colorScheme.primary;

    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBackupSuccessDialog(BackupResult result) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Text('Backup Created!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Entries', '${result.entriesCount}'),
            const SizedBox(height: 8),
            _buildInfoRow('Categories', '${result.categoriesCount}'),
            const SizedBox(height: 8),
            _buildInfoRow('Size', result.fileSizeFormatted),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.folder, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.filePath ?? '',
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              if (result.filePath != null) {
                await _backupService.shareBackupFile(result.filePath!);
              }
            },
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreSuccessDialog(RestoreResult result) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Text('Restore Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Entries Restored', '${result.entriesRestored}'),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Categories Restored',
              '${result.categoriesRestored}',
            ),
            if (result.backupDate != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Backup From', _formatDate(result.backupDate)),
            ],
            const SizedBox(height: 16),
            const Text(
              'Your data has been successfully restored. You may need to restart the app to see all changes.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Pop back to home screen
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDialog(String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Backup & Restore',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _refreshBackups,
            icon: const Icon(Iconsax.refresh),
            tooltip: 'Refresh backups list',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Create Backup Section
              const SectionHeader(
                title: 'Create Backup',
                icon: Iconsax.document_upload,
              ),
              const SizedBox(height: 16),
              _buildCreateBackupCard(),

              const SizedBox(height: 32),

              // Restore Section
              const SectionHeader(
                title: 'Restore Backup',
                icon: Iconsax.document_download,
              ),
              const SizedBox(height: 16),
              _buildRestoreCard(),

              if (_existingBackups.isNotEmpty) ...[
                const SizedBox(height: 32),

                // Existing Backups Section
                const SectionHeader(
                  title: 'Previous Backups',
                  icon: Iconsax.archive,
                ),
                const SizedBox(height: 16),
                ..._existingBackups.map(
                  (backup) => _buildBackupListItem(backup),
                ),
              ],

              const SizedBox(height: 32),

              // Info Card
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateBackupCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _createBackup,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Iconsax.shield_tick,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Encrypted Backup',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Export all your passwords securely',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _restoreFromFile,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Iconsax.import,
                    color: colorScheme.tertiary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restore from File',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Import a .armor backup file',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.folder_open_rounded, color: colorScheme.tertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackupListItem(BackupFileInfo backup) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.document, color: colorScheme.primary),
          ),
          title: Text(
            backup.fileName,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${_formatDate(backup.createdAt)} • ${backup.fileSizeFormatted}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            onSelected: (value) {
              switch (value) {
                case 'restore':
                  _restoreFromExisting(backup);
                  break;
                case 'share':
                  _shareBackup(backup);
                  break;
                case 'delete':
                  _deleteBackup(backup);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Iconsax.import),
                    SizedBox(width: 12),
                    Text('Restore'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded),
                    SizedBox(width: 12),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, color: Colors.red),
                    const SizedBox(width: 12),
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.info_circle, color: colorScheme.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'About Backups',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoItem(
            icon: Iconsax.lock,
            text: 'Backups are encrypted with AES-256 encryption',
          ),
          const SizedBox(height: 8),
          _buildInfoItem(
            icon: Iconsax.key,
            text: 'Master password is required to restore',
          ),
          const SizedBox(height: 8),
          _buildInfoItem(
            icon: Iconsax.document,
            text: 'Backup files have .armor extension',
          ),
          const SizedBox(height: 8),
          _buildInfoItem(
            icon: Icons.cloud_off_rounded,
            text: 'All data stays offline on your device',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurface.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
