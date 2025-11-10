import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/export_models.dart';
import '../../services/database_service.dart';

/// Dialog for configuring and initiating password export
class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  // Export configuration
  ExportFormat _selectedFormat = ExportFormat.pdf; // PDF only now
  ExportDestination _selectedDestination = ExportDestination.device;
  final _emailController = TextEditingController();
  bool _useDefaultPassword = false;
  bool _includeArchived = false;
  bool _includeNotes = true;
  bool _includeTags = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Statistics
  int _totalEntries = 0;
  int _archivedEntries = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Load entry statistics
  Future<void> _loadStatistics() async {
    try {
      final allEntries = await _databaseService.getAllPasswordEntries(
        includeArchived: true,
      );
      final activeEntries = allEntries.where((e) => !e.isArchived).length;
      final archived = allEntries.length - activeEntries;

      setState(() {
        _totalEntries = activeEntries;
        _archivedEntries = archived;
      });
    } catch (e) {
      debugPrint('❌ Failed to load statistics: $e');
    }
  }

  /// Get estimated file size
  String _getEstimatedSize() {
    final count = _includeArchived
        ? _totalEntries + _archivedEntries
        : _totalEntries;

    // PDF: ~15KB base + ~8KB per entry
    final sizeKB = 15 + (count * 8);
    if (sizeKB > 1024) {
      return '${(sizeKB / 1024).toStringAsFixed(1)} MB';
    }
    return '$sizeKB KB';
  }

  /// Validate and initiate export
  Future<void> _handleExport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if password is provided or default password is enabled
    if (!_useDefaultPassword && _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a password or enable default password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create export configuration
      final config = ExportConfig(
        format: _selectedFormat,
        destination: _selectedDestination,
        password: _useDefaultPassword ? '' : _passwordController.text.trim(),
        email: _selectedDestination == ExportDestination.email
            ? _emailController.text.trim()
            : null,
        useDefaultPassword: _useDefaultPassword,
        includeArchived: _includeArchived,
        includeNotes: _includeNotes,
        includeTags: _includeTags,
      );

      // Return the configuration to parent screen
      if (mounted) {
        Navigator.of(context).pop(config);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export setup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entryCount = _includeArchived
        ? _totalEntries + _archivedEntries
        : _totalEntries;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(theme),

                  const SizedBox(height: 24),

                  // Destination selector
                  _buildDestinationSelector(theme),

                  const SizedBox(height: 20),

                  // Password section
                  _buildPasswordSection(theme),

                  const SizedBox(height: 20),

                  // Options section
                  _buildOptionsSection(theme),

                  const SizedBox(height: 20),

                  // Statistics
                  _buildStatistics(theme, entryCount),

                  const SizedBox(height: 20),

                  // Security notice
                  _buildSecurityNotice(theme),

                  const SizedBox(height: 24),

                  // Action buttons
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build dialog header
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Iconsax.document_download,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Export Passwords',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Export your passwords as encrypted file',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build destination selector
  Widget _buildDestinationSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Destination',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDestinationOption(
                theme,
                ExportDestination.device,
                Iconsax.mobile,
                'Device',
                'Save to device storage',
                false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDestinationOption(
                theme,
                ExportDestination.email,
                Iconsax.sms,
                'Email',
                'Coming Soon',
                true,
              ),
            ),
          ],
        ),
        // Show email input if email destination is selected (for future use)
        if (_selectedDestination == ExportDestination.email) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, color: Colors.orange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Email export feature is coming soon! Please use Device export for now.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Build single destination option
  Widget _buildDestinationOption(
    ThemeData theme,
    ExportDestination destination,
    IconData icon,
    String title,
    String subtitle,
    bool isComingSoon,
  ) {
    final isSelected = _selectedDestination == destination;
    final isDisabled = isComingSoon;

    return InkWell(
      onTap: isDisabled
          ? null
          : () => setState(() => _selectedDestination = destination),
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.05)
                : null,
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 32,
                  ),
                  if (isComingSoon)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'SOON',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isComingSoon
                      ? Colors.orange
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: isComingSoon
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build password input section
  Widget _buildPasswordSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Encryption Password',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Use default password checkbox
        CheckboxListTile(
          value: _useDefaultPassword,
          onChanged: (value) =>
              setState(() => _useDefaultPassword = value ?? false),
          title: Text(
            'Use default password',
            style: theme.textTheme.bodyMedium,
          ),
          subtitle: Text(
            'Use the password saved in settings',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),

        const SizedBox(height: 8),

        // Password input field
        if (!_useDefaultPassword)
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter encryption password',
              prefixIcon: const Icon(Iconsax.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Iconsax.eye : Iconsax.eye_slash),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (_useDefaultPassword) return null;

              if (value == null || value.trim().isEmpty) {
                return 'Password is required';
              }

              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }

              return null;
            },
            onChanged: (_) => setState(() {}),
          ),

        // Password strength indicator
        if (!_useDefaultPassword && _passwordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildPasswordStrengthIndicator(theme),
          ),
      ],
    );
  }

  /// Build password strength indicator
  Widget _buildPasswordStrengthIndicator(ThemeData theme) {
    final config = ExportConfig(
      format: _selectedFormat,
      password: _passwordController.text,
    );
    final strength = config.passwordStrength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength.progressValue,
                backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                color: Color(strength.colorValue),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Color(strength.colorValue),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build export options section
  Widget _buildOptionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Options',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        CheckboxListTile(
          value: _includeArchived,
          onChanged: (value) =>
              setState(() => _includeArchived = value ?? false),
          title: Text(
            'Include archived entries',
            style: theme.textTheme.bodyMedium,
          ),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),

        CheckboxListTile(
          value: _includeNotes,
          onChanged: (value) => setState(() => _includeNotes = value ?? true),
          title: Text('Include notes', style: theme.textTheme.bodyMedium),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),

        CheckboxListTile(
          value: _includeTags,
          onChanged: (value) => setState(() => _includeTags = value ?? true),
          title: Text('Include tags', style: theme.textTheme.bodyMedium),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  /// Build export statistics
  Widget _buildStatistics(ThemeData theme, int entryCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                theme,
                'Entries',
                entryCount.toString(),
                Iconsax.document_text_1,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              _buildStatItem(
                theme,
                'Format',
                _selectedFormat.displayName,
                Iconsax.document,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
              _buildStatItem(
                theme,
                'Est. Size',
                _getEstimatedSize(),
                Iconsax.archive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build single statistic item
  Widget _buildStatItem(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build security notice
  Widget _buildSecurityNotice(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.warning_2, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Protection',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your PDF will be password-protected using industry-standard encryption. You will need this password to open the file. Keep it safe - it cannot be recovered if lost.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _isLoading ? null : _handleExport,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Text('Export'),
          ),
        ),
      ],
    );
  }
}
