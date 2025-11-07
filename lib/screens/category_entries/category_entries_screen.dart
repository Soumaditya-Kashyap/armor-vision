import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/password_entry.dart';
import '../../services/database_service.dart';
import '../../utils/icon_helper.dart';
import '../../utils/constants.dart';
import '../../widgets/dialogs/add_entry_dialog.dart';
import '../../widgets/dialogs/password_entry_detail_dialog.dart';

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
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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

  List<PasswordEntry> get _filteredEntries {
    if (_searchQuery.isEmpty) {
      return _categoryEntries;
    }

    return _categoryEntries.where((entry) {
      final query = _searchQuery.toLowerCase();
      return entry.title.toLowerCase().contains(query) ||
          (entry.description?.toLowerCase().contains(query) ?? false) ||
          entry.customFields.any(
            (field) =>
                field.label.toLowerCase().contains(query) ||
                field.value.toLowerCase().contains(query),
          );
    }).toList();
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
              if (_isSearching)
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: _closeSearch,
                  tooltip: 'Close search',
                )
              else
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: _showSearch,
                  tooltip: 'Search in category',
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _isSearching
                  ? _buildSearchBar(context, categoryColor)
                  : Container(
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
                                  IconHelper.getIconData(
                                    widget.category.iconName,
                                  ),
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
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.onSurface,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_filteredEntries.length} ${_filteredEntries.length == 1 ? 'entry' : 'entries'}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.7),
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
          else if (_filteredEntries.isEmpty)
            SliverFillRemaining(
              child: _searchQuery.isNotEmpty
                  ? _buildNoSearchResults(context, categoryColor)
                  : _buildEmptyState(context, categoryColor),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final entry = _filteredEntries[index];
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
                        child: _buildCompactEntryCard(
                          context,
                          entry,
                          categoryColor,
                        ),
                      ),
                    ),
                  );
                }, childCount: _filteredEntries.length),
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

  Widget _buildSearchBar(BuildContext context, Color categoryColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: theme.textTheme.titleMedium,
            decoration: InputDecoration(
              hintText: 'Search entries...',
              hintStyle: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search_rounded, color: categoryColor),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(BuildContext context, Color categoryColor) {
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
                Icons.search_off_rounded,
                size: 64,
                color: categoryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No entries match "$_searchQuery" in this category.\n\nTry a different search term.',
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
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _addNewEntry,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Entry'),
              style: FilledButton.styleFrom(
                backgroundColor: categoryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactEntryCard(
    BuildContext context,
    PasswordEntry entry,
    Color categoryColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _viewEntry(entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconHelper.getIconData(widget.category.iconName),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      entry.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Description or field count
                    Text(
                      entry.description?.isNotEmpty == true
                          ? entry.description!
                          : '${entry.customFields.length} ${entry.customFields.length == 1 ? 'field' : 'fields'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Modified time
                    Text(
                      'Modified ${AppHelpers.formatDate(entry.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
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

  void _viewEntry(PasswordEntry entry) async {
    // Increment access count
    final updatedEntry = entry.copyWith(
      accessCount: entry.accessCount + 1,
      lastAccessedAt: DateTime.now(),
    );
    await DatabaseService().savePasswordEntry(updatedEntry);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PasswordEntryDetailDialog(
        entry: updatedEntry,
        onEntryUpdated: () {
          _loadCategoryEntries(); // Refresh the entries list
        },
      ),
    ).then((_) {
      _loadCategoryEntries(); // Refresh after dialog closes to show updated access count
    });
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
    _searchController.dispose();
    super.dispose();
  }
}
