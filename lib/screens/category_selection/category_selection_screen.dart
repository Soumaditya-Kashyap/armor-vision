import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/password_entry.dart';
import '../../services/database_service.dart';
import '../../widgets/dialogs/add_entry_dialog.dart';
import '../../widgets/dialogs/components/icon_picker_dialog.dart';
import 'components/category_selection_header.dart';
import 'components/category_grid.dart';
import 'components/category_action_buttons.dart';

class CategorySelectionScreen extends StatefulWidget {
  final VoidCallback? onEntryAdded;
  final VoidCallback? onCategoriesChanged;

  const CategorySelectionScreen({
    super.key,
    this.onEntryAdded,
    this.onCategoriesChanged,
  });

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen>
    with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();

  // Animation controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // State variables
  List<Category> _allCategories = [];
  bool _isLoading = true;
  Set<String> _selectedCategories = {};
  bool _isMultiSelectMode = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAllCategories();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  Future<void> _loadAllCategories() async {
    try {
      // Load all categories from database (both preset and user-created)
      final categories = await _databaseService.getAllCategories();

      setState(() {
        _allCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error loading categories: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    // Calculate responsive dimensions with safe constraints
    final maxWidth = screenWidth < 600 ? screenWidth * 0.95 : 600.0;
    final availableHeight = screenHeight - keyboardHeight - 32;
    final maxHeight = isLandscape
        ? availableHeight * 0.95
        : availableHeight * 0.9;

    // Ensure minHeight is never greater than maxHeight
    final minHeight = isLandscape ? 300.0 : 400.0;
    final safeMinHeight = minHeight > maxHeight ? maxHeight * 0.7 : minHeight;

    final dialogPadding = screenWidth < 400 ? 8.0 : 16.0;

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
              minHeight: safeMinHeight,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(isLandscape ? 16 : 24),
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
                  CategorySelectionHeader(
                    isMultiSelectMode: _isMultiSelectMode,
                    onClose: _closeDialog,
                  ),
                  Flexible(
                    child: _isLoading
                        ? _buildLoadingState()
                        : CategoryGrid(
                            categories: _allCategories,
                            selectedCategories: _selectedCategories,
                            isMultiSelectMode: _isMultiSelectMode,
                            onCategoryTap: (category, isSelected) {
                              setState(() {
                                if (_isMultiSelectMode) {
                                  // In multi-select mode, toggle selection
                                  if (isSelected) {
                                    _selectedCategories.remove(category.id);
                                  } else {
                                    _selectedCategories.add(category.id);
                                  }
                                } else {
                                  // In single-select mode, toggle or select single category
                                  if (isSelected) {
                                    _selectedCategories
                                        .clear(); // Unselect if tapped again
                                  } else {
                                    _selectedCategories.clear();
                                    _selectedCategories.add(category.id);
                                  }
                                }
                              });
                            },
                            onCategoryLongPress: (category) {
                              setState(() {
                                // Enable multi-select mode and add this category if not selected
                                _isMultiSelectMode = true;
                                final isSelected = _selectedCategories.contains(
                                  category.id,
                                );
                                if (!isSelected) {
                                  _selectedCategories.add(category.id);
                                }
                              });
                            },
                            onAddNewCategory: _showAddNewCategoryDialog,
                          ),
                  ),
                  CategoryActionButtons(
                    isMultiSelectMode: _isMultiSelectMode,
                    selectedCount: _selectedCategories.length,
                    hasSelection: _selectedCategories.isNotEmpty,
                    onContinue: _proceedToForm,
                    onSingleSelectMode: () {
                      setState(() {
                        _isMultiSelectMode = false;
                        if (_selectedCategories.length > 1) {
                          // Keep only the first selected category
                          final firstSelected = _selectedCategories.first;
                          _selectedCategories.clear();
                          _selectedCategories.add(firstSelected);
                        }
                      });
                    },
                    onCancel: _closeDialog,
                    onDelete: _showDeleteConfirmation,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showAddNewCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddNewCategoryDialog(
        onCategoryAdded: (categoryName, iconName) async {
          try {
            // Generate a random color for the new category
            final random = Random();
            final colors = EntryColor.values;
            final randomColor = colors[random.nextInt(colors.length)];

            // Create new category in database
            final newCategory = Category(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              name: categoryName,
              description: 'Custom category',
              iconName: iconName,
              color: randomColor,
              createdAt: DateTime.now(),
              sortOrder: _allCategories.length,
            );

            await _databaseService.saveCategory(newCategory);

            setState(() {
              _allCategories.add(newCategory);
              _selectedCategories.clear();
              _selectedCategories.add(newCategory.id);
            });

            // Notify parent that categories have changed
            widget.onCategoriesChanged?.call();

            _showSnackBar('Category created successfully!');
          } catch (e) {
            _showSnackBar('Error creating category: $e', isError: true);
          }
        },
      ),
    );
  }

  void _proceedToForm() {
    if (_selectedCategories.isEmpty) return;

    Navigator.of(context).pop(); // Close this dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEntryDialog(
        preSelectedCategories: _selectedCategories.toList(),
        preSelectedCategory:
            _selectedCategories.first, // For backward compatibility
        onEntryAdded: widget.onEntryAdded,
      ),
    );
  }

  void _closeDialog() {
    _slideController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Iconsax.trash,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        title: const Text('Delete Categories?'),
        content: Text(
          'Are you sure you want to delete ${_selectedCategories.length} ${_selectedCategories.length == 1 ? 'category' : 'categories'}?\n\nThis action cannot be undone.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSelectedCategories();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelectedCategories() async {
    try {
      final categoriesToDelete = _allCategories
          .where((cat) => _selectedCategories.contains(cat.name))
          .toList();

      for (final category in categoriesToDelete) {
        await _databaseService.deleteCategory(category.id);
      }

      setState(() {
        _allCategories.removeWhere(
          (cat) => _selectedCategories.contains(cat.name),
        );
        _selectedCategories.clear();
        _isMultiSelectMode = false;
      });

      // Notify parent that categories have changed
      widget.onCategoriesChanged?.call();

      _showSnackBar(
        'Successfully deleted ${categoriesToDelete.length} ${categoriesToDelete.length == 1 ? 'category' : 'categories'}',
      );
    } catch (e) {
      _showSnackBar('Error deleting categories: $e', isError: true);
    }
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
              size: 18,
            ),
            const SizedBox(width: 10),
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

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

// Supporting classes
class CategoryData {
  final String name;
  final IconData icon;
  final String description;
  final Color color;

  CategoryData({
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
}

class _AddNewCategoryDialog extends StatefulWidget {
  final Function(String, String) onCategoryAdded;

  const _AddNewCategoryDialog({required this.onCategoryAdded});

  @override
  State<_AddNewCategoryDialog> createState() => _AddNewCategoryDialogState();
}

class _AddNewCategoryDialogState extends State<_AddNewCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedIconName = 'label';
  IconData _selectedIcon = Iconsax.tag;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AlertDialog(
      title: const Text('Create New Category'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon selector
            InkWell(
              onTap: _showIconPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _selectedIcon,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category Icon',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatIconName(_selectedIconName),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isLandscape ? 16 : 20),

            // Category name input
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Gaming, Health, Crypto',
                prefixIcon: Icon(_selectedIcon),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Category name is required';
                }
                if (value.trim().length < 2) {
                  return 'Category name must be at least 2 characters';
                }
                return null;
              },
              onFieldSubmitted: (_) => _addCategory(),
            ),
            SizedBox(height: isLandscape ? 12 : 16),
            Text(
              'Custom categories help you organize your entries better.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _addCategory, child: const Text('Create')),
      ],
    );
  }

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => IconPickerDialog(
        currentIconName: _selectedIconName,
        onIconSelected: (iconName, iconData) {
          setState(() {
            _selectedIconName = iconName;
            _selectedIcon = iconData;
          });
        },
      ),
    );
  }

  String _formatIconName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _addCategory() {
    if (!_formKey.currentState!.validate()) return;

    final categoryName = _nameController.text.trim();
    widget.onCategoryAdded(categoryName, _selectedIconName);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
