import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/export_service.dart';
import '../../../services/permission_service.dart';

class DataTransparencyCard extends StatefulWidget {
  const DataTransparencyCard({super.key});

  @override
  State<DataTransparencyCard> createState() => _DataTransparencyCardState();
}

class _DataTransparencyCardState extends State<DataTransparencyCard> {
  final _exportService = ExportService();
  final _permissionService = PermissionService();

  bool _isLoading = true;
  bool _isSyncing = false;
  bool _folderExists = false;
  String? _folderPath;
  DateTime? _lastSyncTime;
  int _totalEntries = 0;
  PermissionSummary? _permissionSummary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final folderExists = await _exportService.armorFolderExists();
      final folderPath = await _exportService.getArmorFolderPath();
      final lastSync = _exportService.getLastExportTime();
      final totalEntries = _exportService.getTotalEntriesCount();
      final permissions = await _permissionService.getPermissionSummary();

      if (mounted) {
        setState(() {
          _folderExists = folderExists;
          _folderPath = folderPath;
          _lastSyncTime = lastSync;
          _totalEntries = totalEntries;
          _permissionSummary = permissions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading transparency data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resyncNow() async {
    setState(() => _isSyncing = true);

    try {
      final success = await _exportService.initializeArmorFolder();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? '✅ Folder synced successfully!'
                  : '⚠️ Sync failed. Check permissions.',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _openFolder() async {
    if (_folderPath == null) return;

    try {
      // Copy path to clipboard
      await Clipboard.setData(ClipboardData(text: _folderPath!));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('📋 Folder path copied to clipboard!'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'OK', onPressed: () {}),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening folder: $e');
    }
  }

  String _getLastSyncText() {
    if (_lastSyncTime == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder_open_rounded,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Transparency',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Local vault mirror for trust & backup',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              // Status Row
              _buildInfoRow(
                context,
                icon: _folderExists ? Icons.check_circle : Icons.cancel,
                iconColor: _folderExists ? Colors.green : Colors.orange,
                label: 'Status',
                value: _folderExists ? 'Folder Active' : 'Not Created',
              ),

              const SizedBox(height: 12),

              // Last Synced
              _buildInfoRow(
                context,
                icon: Icons.sync_rounded,
                iconColor: colorScheme.primary,
                label: 'Last Synced',
                value: _getLastSyncText(),
              ),

              const SizedBox(height: 12),

              // Total Entries
              _buildInfoRow(
                context,
                icon: Icons.key_rounded,
                iconColor: colorScheme.tertiary,
                label: 'Entries Exported',
                value: '$_totalEntries entries',
              ),

              const SizedBox(height: 12),

              // Folder Location
              if (_folderPath != null)
                _buildInfoRow(
                  context,
                  icon: Icons.location_on_rounded,
                  iconColor: colorScheme.secondary,
                  label: 'Location',
                  value: _getFriendlyPath(_folderPath!),
                  onTap: _openFolder,
                  trailing: Icon(
                    Icons.copy_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  // Resync Button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isSyncing ? null : _resyncNow,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(_isSyncing ? 'Syncing...' : 'Resync Now'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Open Folder Button
                  if (Platform.isAndroid && _folderExists)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openFolder,
                        icon: const Icon(Icons.folder_open_rounded, size: 20),
                        label: const Text('Copy Path'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Files include password hashes for verification. Open info.txt in the folder for details.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
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
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  String _getFriendlyPath(String path) {
    // Shorten long paths for display
    if (path.length > 40) {
      final parts = path.split('/');
      if (parts.length > 3) {
        return '.../${parts[parts.length - 2]}/${parts.last}';
      }
    }
    return path;
  }
}
