import 'package:flutter/material.dart';
import '../../../models/password_entry.dart';
import '../../../utils/icon_helper.dart';
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
        IconHelper.getIconData(category.iconName),
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
}
