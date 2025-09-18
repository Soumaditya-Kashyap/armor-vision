import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../models/password_entry.dart';
import '../../services/database_service.dart';
import '../custom_field_widget.dart';

class AddEntryDialog extends StatefulWidget {
  final VoidCallback? onEntryAdded;
  final String? preSelectedCategory;
  final List<String>? preSelectedCategories;

  const AddEntryDialog({
    super.key,
    this.onEntryAdded,
    this.preSelectedCategory,
    this.preSelectedCategories,
  });

  @override
  State<AddEntryDialog> createState() => _AddEntryDialogState();
}

class _AddEntryDialogState extends State<AddEntryDialog>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State variables
  List<CustomField> _customFields = [];
  String? _selectedCategory;
  List<String> _selectedTags = [];
  EntryColor _selectedColor = EntryColor.blue;
  bool _isSaving = false;
  bool _isPasswordVisible = false;
  bool _isEditMode = false; // New: Edit mode for field management

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeDefaultFields();

    // Set pre-selected category if provided
    if (widget.preSelectedCategories != null &&
        widget.preSelectedCategories!.isNotEmpty) {
      _selectedCategory = widget.preSelectedCategories!.first;
    } else if (widget.preSelectedCategory != null) {
      _selectedCategory = widget.preSelectedCategory;
    }
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  void _initializeDefaultFields() {
    _customFields = [
      CustomField(
        label: 'Username',
        value: '',
        type: FieldType.username,
        isRequired: true,
        hint: 'Enter your username or email',
      ),
      CustomField(
        label: 'Password',
        value: '',
        type: FieldType.password,
        isRequired: true,
        hint: 'Enter your password',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    // Calculate responsive dimensions
    final maxWidth = screenWidth < 600 ? screenWidth * 0.95 : 500.0;
    final maxHeight = isLandscape
        ? screenHeight * 0.85 - keyboardHeight
        : screenHeight * 0.9 - keyboardHeight;

    // Adjust padding for smaller screens
    final dialogPadding = screenWidth < 400 ? 12.0 : 16.0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(dialogPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              minHeight: isLandscape ? 300 : 400,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(isLandscape ? 20 : 28),
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
                  Flexible(child: _buildForm()),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final headerPadding = isLandscape ? 16.0 : 24.0;
    final iconSize = isLandscape ? 24.0 : 28.0;
    final borderRadius = isLandscape ? 20.0 : 28.0;

    return Container(
      padding: EdgeInsets.all(headerPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isLandscape ? 8 : 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isLandscape ? 12 : 16),
            ),
            child: Icon(
              Icons.add_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Entry',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isLandscape ? 18 : null,
                  ),
                ),
                if (!isLandscape) const SizedBox(height: 4),
                if (!isLandscape)
                  Text(
                    _selectedCategory != null
                        ? 'Category: ${_formatCategoryName(_selectedCategory!)}'
                        : 'Create a new password entry',
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
            onPressed: _closeDialog,
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

  Widget _buildForm() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final formPadding = isLandscape ? 16.0 : 24.0;
    final spacingLarge = isLandscape ? 20.0 : 24.0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(formPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicFields(),
            SizedBox(height: spacingLarge),
            _buildCustomFields(),
            SizedBox(height: spacingLarge),
            _buildNotesField(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Title *',
            hintText: 'e.g., Gmail, Facebook, Bank Account',
            prefixIcon: const Icon(Icons.title_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Brief description (optional)',
            prefixIcon: const Icon(Icons.description_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          textInputAction: TextInputAction.next,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildCustomFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Fields',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            // Edit mode toggle button
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              },
              icon: Icon(
                _isEditMode ? Icons.check_rounded : Icons.edit_rounded,
                size: 20,
              ),
              tooltip: _isEditMode ? 'Done editing' : 'Edit fields',
              style: IconButton.styleFrom(
                backgroundColor: _isEditMode
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                foregroundColor: _isEditMode
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
            ),
            if (_customFields.any((field) => field.type == FieldType.password))
              IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                tooltip: _isPasswordVisible
                    ? 'Hide passwords'
                    : 'Show passwords',
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Show message if no fields
        if (_customFields.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.note_add_rounded,
                  size: 32,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Simple Note Mode',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No fields added. This entry will work as a simple note with title, description, and notes only.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        // Render existing fields
        ..._customFields.asMap().entries.map((entry) {
          final index = entry.key;
          final field = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomFieldWidget(
              field: field,
              isPasswordVisible: _isPasswordVisible,
              onFieldChanged: (updatedField) {
                setState(() {
                  _customFields[index] = updatedField;
                });
              },
              // Show remove button only in edit mode
              onRemoveField: _isEditMode
                  ? () {
                      setState(() {
                        _customFields.removeAt(index);
                      });
                    }
                  : null,
              showPasswordGenerator: field.type == FieldType.password,
            ),
          );
        }).toList(),

        // Add field button (always visible)
        const SizedBox(height: 8),
        _buildAddFieldButton(),
      ],
    );
  }

  Widget _buildAddFieldButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showAddFieldDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Custom Field'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Additional notes or comments (optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          maxLines: 3,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonPadding = isLandscape ? 16.0 : 24.0;
    final buttonHeight = isLandscape ? 12.0 : 16.0;
    final borderRadius = isLandscape ? 20.0 : 28.0;

    return Container(
      padding: EdgeInsets.all(buttonPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      ),
      child: (isLandscape || screenWidth < 400)
          ? Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveEntry,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            height: isLandscape ? 16 : 20,
                            width: isLandscape ? 16 : 20,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save Entry'),
                  ),
                ),
                SizedBox(height: isLandscape ? 8 : 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _closeDialog,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _closeDialog,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
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
                    onPressed: _isSaving ? null : _saveEntry,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save Entry'),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddFieldDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddCustomFieldDialog(
        onFieldAdded: (field) {
          setState(() {
            _customFields.add(field);
          });
        },
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in all required fields', isError: true);
      return;
    }

    // Validate password strength for any password fields that have values
    final passwordFields = _customFields.where(
      (f) => f.type == FieldType.password && f.value.trim().isNotEmpty,
    );

    for (final field in passwordFields) {
      final password = field.value.trim();
      if (password.length < 8) {
        _showSnackBar(
          'Password should be at least 8 characters long',
          isError: true,
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final entry = PasswordEntry(
        id: 'entry_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        customFields: _customFields,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        category: _selectedCategory,
        color: _selectedColor,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        tags: _selectedTags,
      );

      await _databaseService.savePasswordEntry(entry);

      if (mounted) {
        _showSnackBar('Password entry saved successfully!');

        // Add haptic feedback
        HapticFeedback.lightImpact();

        widget.onEntryAdded?.call();
        _closeDialog();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error saving entry: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _closeDialog() {
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }

  String _formatCategoryName(String categoryName) {
    if (categoryName.startsWith('CUSTOM_')) {
      final parts = categoryName.split('_');
      if (parts.length >= 2) {
        return parts[1]
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map(
              (word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
            )
            .join(' ');
      }
    }

    return categoryName
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _AddCustomFieldDialog extends StatefulWidget {
  final Function(CustomField) onFieldAdded;

  const _AddCustomFieldDialog({required this.onFieldAdded});

  @override
  State<_AddCustomFieldDialog> createState() => _AddCustomFieldDialogState();
}

class _AddCustomFieldDialogState extends State<_AddCustomFieldDialog> {
  final TextEditingController _labelController = TextEditingController();
  FieldType _selectedType = FieldType.text;
  bool _isRequired = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Field'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'Field Label',
              hintText: 'e.g., Security Question, PIN',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<FieldType>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Field Type'),
            items: FieldType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_getFieldTypeLabel(type)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Required Field'),
            value: _isRequired,
            onChanged: (value) {
              setState(() {
                _isRequired = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _addField, child: const Text('Add Field')),
      ],
    );
  }

  void _addField() {
    if (_labelController.text.trim().isEmpty) return;

    final field = CustomField(
      label: _labelController.text.trim(),
      value: '',
      type: _selectedType,
      isRequired: _isRequired,
      hint: _getFieldHint(_selectedType),
    );

    widget.onFieldAdded(field);
    Navigator.of(context).pop();
  }

  String _getFieldTypeLabel(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Text';
      case FieldType.password:
        return 'Password';
      case FieldType.email:
        return 'Email';
      case FieldType.url:
        return 'URL';
      case FieldType.number:
        return 'Number';
      case FieldType.note:
        return 'Note';
      case FieldType.phone:
        return 'Phone';
      case FieldType.date:
        return 'Date';
      case FieldType.bankAccount:
        return 'Bank Account';
      case FieldType.creditCard:
        return 'Credit Card';
      case FieldType.socialSecurity:
        return 'Social Security';
      case FieldType.username:
        return 'Username';
      case FieldType.pin:
        return 'PIN';
    }
  }

  String _getFieldHint(FieldType type) {
    switch (type) {
      case FieldType.text:
        return 'Enter text';
      case FieldType.password:
        return 'Enter password';
      case FieldType.email:
        return 'Enter email address';
      case FieldType.url:
        return 'Enter website URL';
      case FieldType.number:
        return 'Enter number';
      case FieldType.note:
        return 'Enter notes';
      case FieldType.phone:
        return 'Enter phone number';
      case FieldType.date:
        return 'Enter date';
      case FieldType.bankAccount:
        return 'Enter account number';
      case FieldType.creditCard:
        return 'Enter card number';
      case FieldType.socialSecurity:
        return 'Enter SSN';
      case FieldType.username:
        return 'Enter username';
      case FieldType.pin:
        return 'Enter PIN';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
}
