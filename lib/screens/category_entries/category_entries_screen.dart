import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/password_entry.dart';
import '../../services/database_service.dart';
import '../../utils/icon_helper.dart';
import '../../utils/constants.dart';
import '../../widgets/password_entry_card.dart';
import '../../widgets/dialogs/add_entry_dialog.dart';

class CategoryEntriesScreen extends StatefulWidget {
  final Category category;

  const CategoryEntriesScreen({super.key, required this.category});

  @override
  State<CategoryEntriesScreen> createState() => _CategoryEntriesScreenState();
}

class _CategoryEntriesScreenState extends State<CategoryEntriesScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  List<PasswordEntry> _categoryEntries = [];
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCategoryEntries();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  Future<void> _loadCategoryEntries() async {
    try {
      setState(() => _isLoading = true);

      // Get all entries that belong to this category
      final allEntries = await _databaseService.getAllPasswordEntries();

      final categoryEntries = allEntries.where((entry) {
        if (entry.category == null || entry.category!.isEmpty) {
          return false;
        }
        return entry.category == widget.category.id;
      }).toList();

      // Sort by most recently updated
      categoryEntries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      setState(() {
        _categoryEntries = categoryEntries;
        _isLoading = false;
      });
    } catch (e) {
      print('ERROR loading category entries: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading entries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = AppHelpers.getEntryColor(widget.category.color);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with category info
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: categoryColor.withOpacity(0.1),
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: _showSearch,
                tooltip: 'Search in category',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withOpacity(0.2),
                      categoryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Category Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            IconHelper.getIconData(widget.category.iconName),
                            color: categoryColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Category Name and Count
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.category.name,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_categoryEntries.length} ${_categoryEntries.length == 1 ? 'entry' : 'entries'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_categoryEntries.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(context, categoryColor))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final entry = _categoryEntries[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: Offset(0, 0.1 * (index + 1)),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                (index * 0.1).clamp(0.0, 1.0),
                                ((index + 1) * 0.1).clamp(0.0, 1.0),
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PasswordEntryCard(
                          entry: entry,
                          onTap: () => _viewEntry(entry),
                        ),
                      ),
                    ),
                  );
                }, childCount: _categoryEntries.length),
              ),
            ),
        ],
      ),
      floatingActionButton: _categoryEntries.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _addNewEntry,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Entry'),
              backgroundColor: categoryColor,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color categoryColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconHelper.getIconData(widget.category.iconName),
                size: 64,
                color: categoryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Entries Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t created any password entries in the ${widget.category.name} category yet.\n\nCreate a new entry and assign it to this category to see it here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearch() {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search functionality coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _addNewEntry() {
    showDialog(
      context: context,
      builder: (context) => AddEntryDialog(
        preSelectedCategory: widget.category.id,
        onEntryAdded: () {
          _loadCategoryEntries();
        },
      ),
    );
  }

  void _viewEntry(PasswordEntry entry) {
    // For now, open edit dialog directly
    _editEntry(entry);
  }

  void _editEntry(PasswordEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AddEntryDialog(
        existingEntry: entry,
        onEntryUpdated: () {
          _loadCategoryEntries();
        },
      ),
    );
  }

  Future<void> _deleteEntry(PasswordEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseService.deletePasswordEntry(entry.id);
        _loadCategoryEntries();
        _showSuccessSnackBar('Entry deleted successfully');
      } catch (e) {
        _showErrorSnackBar('Error deleting entry: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
