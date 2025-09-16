import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/password_entry.dart';
import '../services/database_service.dart';
import '../widgets/dialogs/add_entry_dialog.dart';

class CategorySelectionScreen extends StatefulWidget {
  final VoidCallback? onEntryAdded;

  const CategorySelectionScreen({super.key, this.onEntryAdded});

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
  String? _selectedCategory;

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

  // Helper methods
  IconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'people':
        return Icons.people;
      case 'account_balance':
        return Icons.account_balance;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'work':
        return Icons.work;
      case 'movie':
        return Icons.movie;
      case 'airplanemode_active':
        return Icons.airplanemode_active;
      case 'school':
        return Icons.school;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.label_outline;
    }
  }

  Color _getCategoryColor(EntryColor? entryColor) {
    switch (entryColor) {
      case EntryColor.blue:
        return Colors.blue;
      case EntryColor.purple:
        return Colors.purple;
      case EntryColor.green:
        return Colors.green;
      case EntryColor.amber:
        return Colors.amber;
      case EntryColor.red:
        return Colors.red;
      case EntryColor.teal:
        return Colors.teal;
      case EntryColor.pink:
        return Colors.pink;
      case EntryColor.orange:
        return Colors.orange;
      default:
        return Colors.grey;
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
                  _buildHeader(),
                  Flexible(
                    child: _isLoading
                        ? _buildLoadingState()
                        : _buildCategoryList(),
                  ),
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
    final headerPadding = isLandscape ? 12.0 : 20.0;
    final iconSize = isLandscape ? 20.0 : 24.0;
    final borderRadius = isLandscape ? 16.0 : 24.0;

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
            padding: EdgeInsets.all(isLandscape ? 6 : 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(isLandscape ? 8 : 12),
            ),
            child: Icon(
              Icons.category_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isLandscape ? 16 : 18,
                  ),
                ),
                if (!isLandscape) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Select a category for your new entry',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: _closeDialog,
            icon: Icon(
              Icons.close_rounded,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              size: isLandscape ? 18 : 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.all(isLandscape ? 6 : 8),
              minimumSize: Size.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
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

  Widget _buildCategoryList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 30,
          childAspectRatio: 0.8,
        ),
        itemCount: _allCategories.length + 1, // +1 for add new category
        itemBuilder: (context, index) {
          if (index == _allCategories.length) {
            return _buildAddCategoryCircle();
          }

          final category = _allCategories[index];
          return _buildCategoryCircle(category);
        },
      ),
    );
  }

  Widget _buildCategoryCircle(Category category) {
    final isSelected = _selectedCategory == category.name;
    final categoryColor = _getCategoryColor(category.color);
    final categoryIcon = _getCategoryIcon(category.iconName);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category.name;
        });
        HapticFeedback.lightImpact();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? categoryColor
                  : categoryColor.withOpacity(0.1),
              border: Border.all(
                color: isSelected
                    ? categoryColor
                    : categoryColor.withOpacity(0.3),
                width: isSelected ? 3 : 2,
              ),
            ),
            child: Icon(
              categoryIcon,
              size: 32,
              color: isSelected ? Colors.white : categoryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? categoryColor
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddCategoryCircle() {
    return GestureDetector(
      onTap: _showAddNewCategoryDialog,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.add,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add New',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonPadding = isLandscape ? 12.0 : 20.0;
    final buttonHeight = isLandscape ? 10.0 : 14.0;
    final borderRadius = isLandscape ? 16.0 : 24.0;

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
                    onPressed: _selectedCategory == null
                        ? null
                        : _proceedToForm,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
                SizedBox(height: isLandscape ? 8 : 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _closeDialog,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    onPressed: _closeDialog,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _selectedCategory == null
                        ? null
                        : _proceedToForm,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddNewCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddNewCategoryDialog(
        onCategoryAdded: (categoryName) async {
          try {
            // Create new category in database
            final newCategory = Category(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              name: categoryName,
              description: 'Custom category',
              iconName: 'label',
              color: EntryColor.blue,
              createdAt: DateTime.now(),
              sortOrder: _allCategories.length,
            );

            await _databaseService.saveCategory(newCategory);

            setState(() {
              _allCategories.add(newCategory);
              _selectedCategory = newCategory.id;
            });

            _showSnackBar('Category created successfully!');
          } catch (e) {
            _showSnackBar('Error creating category: $e', isError: true);
          }
        },
      ),
    );
  }

  void _proceedToForm() {
    if (_selectedCategory == null) return;

    Navigator.of(context).pop(); // Close this dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEntryDialog(
        preSelectedCategory: _selectedCategory,
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
  final Function(String) onCategoryAdded;

  const _AddNewCategoryDialog({required this.onCategoryAdded});

  @override
  State<_AddNewCategoryDialog> createState() => _AddNewCategoryDialogState();
}

class _AddNewCategoryDialogState extends State<_AddNewCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Gaming, Health, Crypto',
                prefixIcon: Icon(Icons.label_outline),
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

  void _addCategory() {
    if (!_formKey.currentState!.validate()) return;

    final categoryName = _nameController.text.trim();
    widget.onCategoryAdded(categoryName);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
