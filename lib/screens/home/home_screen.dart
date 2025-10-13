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
                          onEntryTap: _openEntryDetails,
                          onFavoriteToggle: _toggleFavorite,
                        ),
                        EntriesList(
                          entries: _filteredFavorites,
                          onEntryTap: _openEntryDetails,
                          onFavoriteToggle: _toggleFavorite,
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
