import 'package:flutter/material.dart';
import '../../../models/password_entry.dart';
import '../../../utils/constants.dart';

class CategorySelectorWidget extends StatelessWidget {
  final String? selectedCategory;
  final List<Category> categories;
  final Function(String?) onCategorySelected;

  const CategorySelectorWidget({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = selectedCategory == category.id;
            return _buildCategoryChip(category, isSelected, theme, colorScheme);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    Category category,
    bool isSelected,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return FilterChip(
      selected: isSelected,
      label: Text(category.name),
      avatar: Icon(
        _getCategoryIcon(category.iconName),
        size: 18,
        color: isSelected
            ? colorScheme.onPrimary
            : AppHelpers.getEntryColor(category.color),
      ),
      onSelected: (selected) {
        onCategorySelected(selected ? category.id : null);
      },
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.outline.withOpacity(0.3),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'account_circle':
        return Icons.account_circle_rounded;
      case 'people':
        return Icons.people_rounded;
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'email':
        return Icons.email_rounded;
      default:
        return Icons.folder_rounded;
    }
  }
}
