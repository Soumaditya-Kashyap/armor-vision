import 'package:flutter/material.dart';
import '../models/password_entry.dart';
import '../services/database_service.dart';
import '../utils/icon_helper.dart';

class CategorySelector extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final DatabaseService _databaseService = DatabaseService();
  List<Category> _categories = [];
  bool _isLoading = true;
  final TextEditingController _newCategoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _databaseService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildCategoryGrid(),
        const SizedBox(height: 12),
        _buildAddCategoryButton(),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip(null, 'No Category', Icons.help_outline),
                ..._categories.map(
                  (category) => _buildCategoryChip(
                    category.id,
                    category.name,
                    IconHelper.getIconData(category.iconName),
                    color: _getCategoryColor(category.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String? id,
    String name,
    IconData icon, {
    Color? color,
  }) {
    final isSelected = widget.selectedCategory == id;

    return FilterChip(
      selected: isSelected,
      onSelected: (selected) {
        widget.onCategorySelected(selected ? id : null);
      },
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : color ?? Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 6),
          Text(name),
        ],
      ),
      backgroundColor: color?.withOpacity(0.1),
      selectedColor: color ?? Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      side: BorderSide(
        color: isSelected
            ? (color ?? Theme.of(context).colorScheme.primary)
            : Theme.of(context).colorScheme.outline.withOpacity(0.3),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildAddCategoryButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showAddCategoryDialog,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('Add New Category'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _newCategoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Gaming, Travel, etc.',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Text(
              'Choose an icon and color for your category:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _buildIconColorSelector(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newCategoryController.clear();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _addNewCategory,
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconColorSelector() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Sample icon and color preview
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.folder_rounded,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Custom icon selection coming soon!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _addNewCategory() async {
    final name = _newCategoryController.text.trim();
    if (name.isEmpty) return;

    try {
      final newCategory = Category(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: 'Custom category',
        color: EntryColor.blue, // Default color for now
        iconName: 'folder', // Default icon for now
        createdAt: DateTime.now(),
        sortOrder: _categories.length + 1,
      );

      await _databaseService.saveCategory(newCategory);
      await _loadCategories();

      if (mounted) {
        Navigator.of(context).pop();
        _newCategoryController.clear();

        // Auto-select the newly created category
        widget.onCategorySelected(newCategory.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "$name" added successfully!'),
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
            content: Text('Error adding category: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Color _getCategoryColor(EntryColor color) {
    switch (color) {
      case EntryColor.blue:
        return Colors.blue;
      case EntryColor.green:
        return Colors.green;
      case EntryColor.orange:
        return Colors.orange;
      case EntryColor.red:
        return Colors.red;
      case EntryColor.purple:
        return Colors.purple;
      case EntryColor.teal:
        return Colors.teal;
      case EntryColor.pink:
        return Colors.pink;
      case EntryColor.indigo:
        return Colors.indigo;
      case EntryColor.amber:
        return Colors.amber;
      case EntryColor.gray:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }
}
