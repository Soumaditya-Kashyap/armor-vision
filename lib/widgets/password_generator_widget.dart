import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class PasswordAnalyzerWidget extends StatefulWidget {
  final String password;
  final VoidCallback? onClose;

  const PasswordAnalyzerWidget({
    super.key,
    required this.password,
    this.onClose,
  });

  @override
  State<PasswordAnalyzerWidget> createState() => _PasswordAnalyzerWidgetState();
}

class _PasswordAnalyzerWidgetState extends State<PasswordAnalyzerWidget> {
  int _passwordStrength = 0;
  List<String> _strengthIssues = [];
  List<String> _strengthBenefits = [];

  @override
  void initState() {
    super.initState();
    _analyzePassword();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 650),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPasswordDisplay(),
                    const SizedBox(height: 24),
                    _buildPasswordAnalysis(),
                    const SizedBox(height: 24),
                    _buildEncryptionDetails(),
                    const SizedBox(height: 24),
                    _buildStrengthIndicator(),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.vpn_key_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Encryption Analysis',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Password security and encryption details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your Password',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _copyPassword,
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy password',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: SelectableText(
              widget.password,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password Analysis',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Password Statistics
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              _buildStatRow('Length', '${widget.password.length} characters'),
              const SizedBox(height: 8),
              _buildStatRow('Character Types', _getCharacterTypesCount()),
              const SizedBox(height: 8),
              _buildStatRow('Entropy', '~${_calculateEntropy()} bits'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Issues and Benefits
        if (_strengthIssues.isNotEmpty) ...[
          _buildIssuesSection(),
          const SizedBox(height: 16),
        ],

        if (_strengthBenefits.isNotEmpty) ...[_buildBenefitsSection()],
      ],
    );
  }

  Widget _buildEncryptionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Armor Security Features',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Security Features
        _buildSecurityFeature(
          Icons.security_rounded,
          'AES-256-GCM Encryption',
          'Military-grade encryption standard',
          'Your password is encrypted with the same security used by banks and governments.',
        ),

        _buildSecurityFeature(
          Icons.key_rounded,
          'Hardware-Backed Storage',
          'Keys stored in secure hardware',
          'Encryption keys are protected by your device\'s secure hardware when available.',
        ),

        _buildSecurityFeature(
          Icons.shuffle_rounded,
          'Unique Salt & IV',
          'Each field encrypted differently',
          'Every password gets its own encryption salt and initialization vector.',
        ),

        _buildSecurityFeature(
          Icons.visibility_off_rounded,
          'Zero-Knowledge Design',
          'We cannot see your passwords',
          'Even if our servers were compromised, your data remains encrypted and unreadable.',
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildIssuesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                'Security Issues Found',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_strengthIssues.map(
            (issue) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.red)),
                  Expanded(
                    child: Text(
                      issue,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Security Strengths',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_strengthBenefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: Colors.green)),
                  Expanded(
                    child: Text(
                      benefit,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(
    IconData icon,
    String title,
    String subtitle,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              _getStrengthLabel(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: _getStrengthColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _passwordStrength / 4,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.outline.withOpacity(0.2),
          color: _getStrengthColor(),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  // Analysis methods
  void _analyzePassword() {
    setState(() {
      _passwordStrength = _calculatePasswordStrength(widget.password);
      _strengthIssues = _getPasswordIssues(widget.password);
      _strengthBenefits = _getPasswordBenefits(widget.password);
    });
  }

  String _getCharacterTypesCount() {
    int types = 0;
    if (widget.password.contains(RegExp(r'[a-z]'))) types++;
    if (widget.password.contains(RegExp(r'[A-Z]'))) types++;
    if (widget.password.contains(RegExp(r'[0-9]'))) types++;
    if (widget.password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]')))
      types++;
    return '$types of 4 types';
  }

  int _calculateEntropy() {
    int charsetSize = 0;
    if (widget.password.contains(RegExp(r'[a-z]'))) charsetSize += 26;
    if (widget.password.contains(RegExp(r'[A-Z]'))) charsetSize += 26;
    if (widget.password.contains(RegExp(r'[0-9]'))) charsetSize += 10;
    if (widget.password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]')))
      charsetSize += 32;

    if (charsetSize == 0) return 0;

    // Entropy = log2(charsetSize^length)
    return (widget.password.length * (log(charsetSize) / log(2))).round();
  }

  List<String> _getPasswordIssues(String password) {
    List<String> issues = [];

    if (password.length < 8) {
      issues.add('Password is too short (less than 8 characters)');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      issues.add('Missing lowercase letters');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      issues.add('Missing uppercase letters');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      issues.add('Missing numbers');
    }

    if (!password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      issues.add('Missing special characters');
    }

    // Check for common patterns
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) {
      issues.add('Contains repeated characters (3+ in a row)');
    }

    if (RegExp(
      r'(012|123|234|345|456|567|678|789|890|abc|bcd|cde|def|efg|fgh|ghi|hij|ijk|jkl|klm|lmn|mno|nop|opq|pqr|qrs|rst|stu|tuv|uvw|vwx|wxy|xyz)',
      caseSensitive: false,
    ).hasMatch(password)) {
      issues.add('Contains sequential characters');
    }

    // Check for common words (basic check)
    final commonWords = [
      'password',
      'admin',
      'user',
      'login',
      'welcome',
      'qwerty',
      'letmein',
      'monkey',
      'dragon',
    ];
    for (String word in commonWords) {
      if (password.toLowerCase().contains(word)) {
        issues.add('Contains common word: "$word"');
        break;
      }
    }

    return issues;
  }

  List<String> _getPasswordBenefits(String password) {
    List<String> benefits = [];

    if (password.length >= 12) {
      benefits.add('Good length (12+ characters)');
    } else if (password.length >= 8) {
      benefits.add('Adequate length (8+ characters)');
    }

    if (password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]'))) {
      benefits.add('Uses both uppercase and lowercase letters');
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      benefits.add('Includes numbers');
    }

    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]'))) {
      benefits.add('Includes special characters');
    }

    if (password.length >= 16) {
      benefits.add('Excellent length for maximum security');
    }

    // Check character diversity
    Set<String> uniqueChars = password.split('').toSet();
    if (uniqueChars.length / password.length > 0.7) {
      benefits.add('Good character diversity');
    }

    return benefits;
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character diversity
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]')))
      strength++;

    return (strength / 6 * 4).round().clamp(0, 4);
  }

  String _getStrengthLabel() {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  Color _getStrengthColor() {
    switch (_passwordStrength) {
      case 0:
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow.shade700;
      case 4:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  void _copyPassword() {
    Clipboard.setData(ClipboardData(text: widget.password));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
