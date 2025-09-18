import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import 'password_generator_widget.dart';

class CustomFieldWidget extends StatefulWidget {
  final CustomField field;
  final bool isPasswordVisible;
  final Function(CustomField) onFieldChanged;
  final VoidCallback? onRemoveField;
  final bool showPasswordGenerator;

  const CustomFieldWidget({
    super.key,
    required this.field,
    required this.isPasswordVisible,
    required this.onFieldChanged,
    this.onRemoveField,
    this.showPasswordGenerator = false,
  });

  @override
  State<CustomFieldWidget> createState() => _CustomFieldWidgetState();
}

class _CustomFieldWidgetState extends State<CustomFieldWidget>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _removeButtonAnimationController;
  late Animation<double> _removeButtonAnimation;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.field.value);
    _obscureText =
        widget.field.type == FieldType.password && !widget.isPasswordVisible;

    // Initialize animation controller for remove button
    _removeButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _removeButtonAnimation = CurvedAnimation(
      parent: _removeButtonAnimationController,
      curve: Curves.easeInOut,
    );

    // Start animation if remove button should be visible
    if (widget.onRemoveField != null) {
      _removeButtonAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(CustomFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.value != widget.field.value) {
      _controller.text = widget.field.value;
    }
    if (oldWidget.isPasswordVisible != widget.isPasswordVisible) {
      _obscureText =
          widget.field.type == FieldType.password && !widget.isPasswordVisible;
    }

    // Animate remove button visibility
    if (oldWidget.onRemoveField != widget.onRemoveField) {
      if (widget.onRemoveField != null) {
        _removeButtonAnimationController.forward();
      } else {
        _removeButtonAnimationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildFieldHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildTextField(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          // Main content row - never changes size
          Row(
            children: [
              Icon(
                _getFieldIcon(),
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.field.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (widget.showPasswordGenerator) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.field.value.isEmpty
                      ? null
                      : _showPasswordAnalyzer,
                  icon: const Icon(Icons.vpn_key_rounded),
                  tooltip: widget.field.value.isEmpty
                      ? 'Enter password to analyze'
                      : 'Analyze Password Encryption',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
              // Reserve space for required badge and minus button
              const SizedBox(width: 120), // Enough space for both
            ],
          ),
          // Required badge - animates position naturally
          if (widget.field.isRequired)
            Positioned(
              right: 50, // Better balanced position
              top: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _removeButtonAnimation,
                builder: (context, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.8, 0.0), // Start closer, move less
                      end: Offset.zero, // To its reserved position
                    ).animate(_removeButtonAnimation),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Required',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // Minus button positioned absolutely - doesn't affect layout
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: _removeButtonAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0), // Start off screen
                    end: Offset.zero, // Slide to final position
                  ).animate(_removeButtonAnimation),
                  child: FadeTransition(
                    opacity: _removeButtonAnimation,
                    child: widget.onRemoveField != null
                        ? IconButton(
                            onPressed: widget.onRemoveField,
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                            ),
                            tooltip: 'Remove Field',
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(8),
                              minimumSize: Size.zero,
                              visualDensity: VisualDensity.compact,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _controller,
      obscureText: _obscureText,
      keyboardType: _getKeyboardType(),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: widget.field.hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        suffixIcon: _buildSuffixIcon(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: (value) {
        if (widget.field.isRequired &&
            (value == null || value.trim().isEmpty)) {
          return '${widget.field.label} is required';
        }
        return _validateFieldType(value);
      },
      onChanged: (value) {
        final updatedField = widget.field.copyWith(value: value);
        widget.onFieldChanged(updatedField);
      },
    );
  }

  Widget? _buildSuffixIcon() {
    switch (widget.field.type) {
      case FieldType.password:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.field.value.isNotEmpty)
              IconButton(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy to clipboard',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            IconButton(
              onPressed: _togglePasswordVisibility,
              icon: Icon(
                _obscureText
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              tooltip: _obscureText ? 'Show password' : 'Hide password',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        );
      case FieldType.email:
      case FieldType.username:
        return widget.field.value.isNotEmpty
            ? IconButton(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy to clipboard',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  visualDensity: VisualDensity.compact,
                ),
              )
            : null;
      case FieldType.url:
        return widget.field.value.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: 'Copy to clipboard',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  IconButton(
                    onPressed: _openUrl,
                    icon: const Icon(Icons.open_in_new_rounded),
                    tooltip: 'Open URL',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              )
            : null;
      default:
        return widget.field.value.isNotEmpty
            ? IconButton(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Copy to clipboard',
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: Size.zero,
                  visualDensity: VisualDensity.compact,
                ),
              )
            : null;
    }
  }

  IconData _getFieldIcon() {
    switch (widget.field.type) {
      case FieldType.text:
        return Icons.text_fields_rounded;
      case FieldType.password:
        return Icons.lock_rounded;
      case FieldType.email:
        return Icons.email_rounded;
      case FieldType.url:
        return Icons.link_rounded;
      case FieldType.number:
        return Icons.numbers_rounded;
      case FieldType.note:
        return Icons.note_rounded;
      case FieldType.phone:
        return Icons.phone_rounded;
      case FieldType.date:
        return Icons.calendar_today_rounded;
      case FieldType.bankAccount:
        return Icons.account_balance_rounded;
      case FieldType.creditCard:
        return Icons.credit_card_rounded;
      case FieldType.socialSecurity:
        return Icons.security_rounded;
      case FieldType.username:
        return Icons.person_rounded;
      case FieldType.pin:
        return Icons.pin_rounded;
    }
  }

  TextInputType _getKeyboardType() {
    switch (widget.field.type) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.url:
        return TextInputType.url;
      case FieldType.number:
      case FieldType.pin:
        return TextInputType.number;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.note:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  String? _validateFieldType(String? value) {
    if (value == null || value.isEmpty) return null;

    switch (widget.field.type) {
      case FieldType.email:
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        break;
      case FieldType.url:
        if (!RegExp(r'^https?://').hasMatch(value)) {
          return 'Please enter a valid URL starting with http:// or https://';
        }
        break;
      case FieldType.phone:
        if (!RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(value)) {
          return 'Please enter a valid phone number';
        }
        break;
      case FieldType.pin:
        if (!RegExp(r'^\d+$').hasMatch(value)) {
          return 'PIN should contain only numbers';
        }
        break;
      default:
        break;
    }
    return null;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.field.value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.field.label} copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openUrl() {
    // URL opening logic would go here
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${widget.field.value}...'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showPasswordAnalyzer() {
    if (widget.field.value.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) =>
          PasswordAnalyzerWidget(password: widget.field.value),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeButtonAnimationController.dispose();
    super.dispose();
  }
}
