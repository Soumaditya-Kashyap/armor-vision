import 'package:flutter/material.dart';
import '../../models/password_entry.dart';
import '../../services/database_service.dart';
import '../../widgets/dialogs/password_entry_detail_dialog.dart';
import '../category_selection/category_selection_screen.dart';
import 'components/home_app_bar.dart';
import 'components/home_search_bar.dart';
import 'components/home_tab_bar.dart';
import 'components/entries_list.dart';
import 'components/categories_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  List<PasswordEntry> _allEntries = [];
  List<PasswordEntry> _favoriteEntries = [];
  List<Category> _categories = [];

  String _searchQuery = '';
  bool _isLoading = true;
  int _currentTabIndex = 0;

  // Selection mode state
  bool _isSelectionMode = false;
  final Set<String> _selectedEntryIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure database is initialized
      if (!_databaseService.isInitialized) {
        await _databaseService.initialize();
      }

      final entries = await _databaseService.getAllPasswordEntries();
      final categories = await _databaseService.getAllCategories();
      final favorites = entries.where((e) => e.isFavorite).toList();

      setState(() {
        _allEntries = entries;
        _favoriteEntries = favorites;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _allEntries = [];
        _favoriteEntries = [];
        _categories = [];
        _isLoading = false;
      });

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  List<PasswordEntry> get _filteredEntries {
    var entries = _allEntries;

    if (_searchQuery.isNotEmpty) {
      entries = entries.where((entry) {
        return entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (entry.description?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ==
                true);
      }).toList();
    }

    // Sort by latest first (newest to oldest)
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return entries;
  }

  List<PasswordEntry> get _filteredFavorites {
    var entries = _favoriteEntries;

    if (_searchQuery.isNotEmpty) {
      entries = entries.where((entry) {
        return entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (entry.description?.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ==
                true);
      }).toList();
    }

    // Sort by latest first (newest to oldest)
    entries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            HomeAppBar(
              totalEntries: _allEntries.length,
              isSelectionMode: _isSelectionMode,
              selectedCount: _selectedEntryIds.length,
              onDeleteTap: _confirmDelete,
              onSettingsTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
              onViewModeTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('More view options coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            // Search and Tabs Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  HomeSearchBar(
                    onSearchChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  HomeTabBar(
                    currentIndex: _currentTabIndex,
                    allCount: _filteredEntries.length,
                    favoritesCount: _filteredFavorites.length,
                    categoriesCount: _categories.length,
                    onTabChanged: (index) {
                      setState(() {
                        _currentTabIndex = index;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : IndexedStack(
                      index: _currentTabIndex,
                      children: [
                        EntriesList(
                          entries: _filteredEntries,
                          onEntryTap: _handleEntryTap,
                          onEntryLongPress: _handleEntryLongPress,
                          onFavoriteToggle: _toggleFavorite,
                          selectedEntryIds: _selectedEntryIds,
                          isSelectionMode: _isSelectionMode,
                        ),
                        EntriesList(
                          entries: _filteredFavorites,
                          onEntryTap: _handleEntryTap,
                          onEntryLongPress: _handleEntryLongPress,
                          onFavoriteToggle: _toggleFavorite,
                          selectedEntryIds: _selectedEntryIds,
                          isSelectionMode: _isSelectionMode,
                          emptyStateTitle: 'No Favorites Yet',
                          emptyStateSubtitle:
                              'Mark your most important passwords as favorites by tapping the heart icon. They\'ll appear here for quick access.',
                          emptyStateIcon: Icons.favorite_outline_rounded,
                        ),
                        CategoriesGrid(
                          categories: _categories,
                          allEntries: _allEntries,
                          onCategoryTap: (category) {
                            // TODO: Open category view
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Opening ${category.name} category...',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEntryDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Entry'),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Selection mode handlers
  void _handleEntryTap(PasswordEntry entry) {
    if (_isSelectionMode) {
      _toggleSelection(entry);
    } else {
      _openEntryDetails(entry);
    }
  }

  void _handleEntryLongPress(PasswordEntry entry) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedEntryIds.add(entry.id);
      });
    } else {
      _toggleSelection(entry);
    }
  }

  void _toggleSelection(PasswordEntry entry) {
    setState(() {
      if (_selectedEntryIds.contains(entry.id)) {
        _selectedEntryIds.remove(entry.id);
        // Exit selection mode if no entries selected
        if (_selectedEntryIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedEntryIds.add(entry.id);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedEntryIds.clear();
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          _DeleteConfirmationDialog(count: _selectedEntryIds.length),
    );

    if (confirmed == true) {
      await _deleteSelectedEntries();
    }
  }

  Future<void> _deleteSelectedEntries() async {
    try {
      // Delete each selected entry
      for (final id in _selectedEntryIds) {
        await _databaseService.deletePasswordEntry(id);
      }

      // Show success message
      final count = _selectedEntryIds.length;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deleted $count ${count == 1 ? 'entry' : 'entries'} successfully',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Exit selection mode and refresh
      _cancelSelection();
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete entries: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _openEntryDetails(PasswordEntry entry) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => PasswordEntryDetailDialog(
        entry: entry,
        onEntryUpdated: () {
          _loadData(); // Refresh the entries list
        },
      ),
    );
  }

  Future<void> _toggleFavorite(PasswordEntry entry) async {
    try {
      final updatedEntry = entry.copyWith(
        isFavorite: !entry.isFavorite,
        updatedAt: DateTime.now(),
      );

      await _databaseService.savePasswordEntry(updatedEntry);
      await _loadData(); // Refresh data

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedEntry.isFavorite
                ? 'Added to favorites'
                : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorite: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showAddEntryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CategorySelectionScreen(
        onEntryAdded: () {
          _loadData(); // Refresh the entries list
        },
        onCategoriesChanged: () {
          _loadData(); // Refresh when categories are added or deleted
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Delete Confirmation Dialog
class _DeleteConfirmationDialog extends StatelessWidget {
  final int count;

  const _DeleteConfirmationDialog({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 32,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Delete ${count == 1 ? 'Entry' : 'Entries'}?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              count == 1
                  ? 'Are you sure you want to permanently delete this entry? This action cannot be undone.'
                  : 'Are you sure you want to permanently delete $count entries? This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: colorScheme.outline, width: 1.5),
                    ),
                    child: Text(
                      'Cancel',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Delete Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
