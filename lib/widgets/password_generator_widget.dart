import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class PasswordGeneratorWidget extends StatefulWidget {
  final Function(String) onPasswordGenerated;

  const PasswordGeneratorWidget({super.key, required this.onPasswordGenerated});

  @override
  State<PasswordGeneratorWidget> createState() =>
      _PasswordGeneratorWidgetState();
}

class _PasswordGeneratorWidgetState extends State<PasswordGeneratorWidget> {
  double _length = 16;
  bool _includeUppercase = true;
  bool _includeLowercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _excludeSimilar = false;
  bool _excludeAmbiguous = false;

  String _generatedPassword = '';
  int _passwordStrength = 0;

  // Character sets
  static const String _uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  static const String _numberChars = '0123456789';
  static const String _symbolChars = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
  static const String _similarChars = 'il1Lo0O';
  static const String _ambiguousChars = '{}[]()\/\\\'\"~,;<>.';

  @override
  void initState() {
    super.initState();
    _generatePassword();
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
                    _buildLengthSlider(),
                    const SizedBox(height: 24),
                    _buildCharacterOptions(),
                    const SizedBox(height: 24),
                    _buildAdvancedOptions(),
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
                  'Password Generator',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate a secure password',
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
                'Generated Password',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _generatePassword,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Generate new password',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
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
              _generatedPassword,
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

  Widget _buildLengthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Length',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_length.round()} characters',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _length,
            min: 4,
            max: 50,
            divisions: 46,
            onChanged: (value) {
              setState(() {
                _length = value;
              });
              _generatePassword();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Character Types',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildOptionTile('Uppercase Letters (A-Z)', _includeUppercase, (value) {
          setState(() {
            _includeUppercase = value;
          });
          _generatePassword();
        }, 'ABCDEFG'),
        _buildOptionTile('Lowercase Letters (a-z)', _includeLowercase, (value) {
          setState(() {
            _includeLowercase = value;
          });
          _generatePassword();
        }, 'abcdefg'),
        _buildOptionTile('Numbers (0-9)', _includeNumbers, (value) {
          setState(() {
            _includeNumbers = value;
          });
          _generatePassword();
        }, '1234567'),
        _buildOptionTile('Symbols (!@#\$%^&*)', _includeSymbols, (value) {
          setState(() {
            _includeSymbols = value;
          });
          _generatePassword();
        }, '!@#\$%^&*'),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Options',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildOptionTile(
          'Exclude Similar Characters',
          _excludeSimilar,
          (value) {
            setState(() {
              _excludeSimilar = value;
            });
            _generatePassword();
          },
          'il1Lo0O',
          subtitle: 'Avoid confusing characters like i, l, 1, L, o, 0, O',
        ),
        _buildOptionTile(
          'Exclude Ambiguous Characters',
          _excludeAmbiguous,
          (value) {
            setState(() {
              _excludeAmbiguous = value;
            });
            _generatePassword();
          },
          '{}[]()\\/',
          subtitle: 'Avoid characters that may cause issues in some systems',
        ),
      ],
    );
  }

  Widget _buildOptionTile(
    String title,
    bool value,
    Function(bool) onChanged,
    String example, {
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              )
            : Text(
                example,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
        value: value,
        onChanged: (newValue) => onChanged(newValue ?? false),
        controlAffinity: ListTileControlAffinity.trailing,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () {
                widget.onPasswordGenerated(_generatedPassword);
                Navigator.of(context).pop();
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Use This Password'),
            ),
          ),
        ],
      ),
    );
  }

  void _generatePassword() {
    String charset = '';

    if (_includeUppercase) charset += _uppercaseChars;
    if (_includeLowercase) charset += _lowercaseChars;
    if (_includeNumbers) charset += _numberChars;
    if (_includeSymbols) charset += _symbolChars;

    if (_excludeSimilar) {
      for (String char in _similarChars.split('')) {
        charset = charset.replaceAll(char, '');
      }
    }

    if (_excludeAmbiguous) {
      for (String char in _ambiguousChars.split('')) {
        charset = charset.replaceAll(char, '');
      }
    }

    if (charset.isEmpty) {
      setState(() {
        _generatedPassword = '';
        _passwordStrength = 0;
      });
      return;
    }

    final random = Random.secure();
    final password = List.generate(
      _length.round(),
      (index) => charset[random.nextInt(charset.length)],
    ).join();

    setState(() {
      _generatedPassword = password;
      _passwordStrength = _calculatePasswordStrength(password);
    });
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
    Clipboard.setData(ClipboardData(text: _generatedPassword));
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
