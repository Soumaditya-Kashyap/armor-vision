import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/password_entry.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final Set<String> selectedCategories;
  final bool isMultiSelectMode;
  final Function(Category, bool) onCategoryTap;
  final Function(Category) onCategoryLongPress;
  final VoidCallback onAddNewCategory;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.isMultiSelectMode,
    required this.onCategoryTap,
    required this.onCategoryLongPress,
    required this.onAddNewCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 30,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length + 1, // +1 for add new category
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return _buildAddCategoryCircle(context);
          }

          final category = categories[index];
          return _buildCategoryCircle(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCircle(BuildContext context, Category category) {
    final isSelected = selectedCategories.contains(category.name);
    final categoryColor = _getCategoryColor(category.color);
    final categoryIcon = _getCategoryIcon(category.iconName);

    return GestureDetector(
      onTap: () {
        onCategoryTap(category, isSelected);
        HapticFeedback.lightImpact();
      },
      onLongPress: () {
        onCategoryLongPress(category);
        HapticFeedback.mediumImpact();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
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
              // Multi-select indicator
              if (isMultiSelectMode)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.green : Colors.grey.shade300,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.circle_outlined,
                      size: 12,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
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

  Widget _buildAddCategoryCircle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onAddNewCategory,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(Icons.add, size: 32, color: colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add New',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.primary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
}
