import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/password_entry.dart';
import '../../models/app_settings.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/password_entry_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();

  List<PasswordEntry> _allEntries = [];
  List<PasswordEntry> _favoriteEntries = [];
  List<Category> _categories = [];

  String _searchQuery = '';
  bool _isLoading = true;
  ViewMode _viewMode = ViewMode.grid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create sample data if needed (for testing)
      await _databaseService.createSampleData();

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
      setState(() {
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
            (entry.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ==
                true);
      }).toList();
    }

    return entries;
  }

  List<PasswordEntry> get _filteredFavorites {
    var entries = _favoriteEntries;

    if (_searchQuery.isNotEmpty) {
      entries = entries.where((entry) {
        return entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (entry.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ==
                true);
      }).toList();
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Armor',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _viewMode = _viewMode == ViewMode.grid
                                    ? ViewMode.list
                                    : ViewMode.grid;
                              });
                            },
                            icon: Icon(
                              _viewMode == ViewMode.grid
                                  ? Icons.view_list_rounded
                                  : Icons.grid_view_rounded,
                            ),
                            tooltip: _viewMode == ViewMode.grid
                                ? 'List view'
                                : 'Grid view',
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Settings
                            },
                            icon: const Icon(Icons.settings_rounded),
                            tooltip: 'Settings',
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search your vault...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: colorScheme.onPrimary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      tabs: [
                        Tab(
                          child: FittedBox(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.all_inclusive_rounded,
                                    size: 14),
                                const SizedBox(width: 2),
                                Text('All (${_filteredEntries.length})'),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.favorite_rounded, size: 14),
                                const SizedBox(width: 2),
                                Text('Fav (${_filteredFavorites.length})'),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.category_rounded, size: 14),
                                const SizedBox(width: 2),
                                Text('Cat (${_categories.length})'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEntriesList(_filteredEntries),
                        _buildEntriesList(_filteredFavorites),
                        _buildCategoriesList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddEntryDialog();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Entry'),
      ),
    );
  }

  Widget _buildEntriesList(List<PasswordEntry> entries) {
    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    if (_viewMode == ViewMode.grid) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: entries.length,
          itemBuilder: (context, index) {
            return PasswordEntryCard(
              entry: entries[index],
              onTap: () => _openEntryDetails(entries[index]),
              onFavoriteToggle: () => _toggleFavorite(entries[index]),
            );
          },
        ),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PasswordEntryCard(
              entry: entries[index],
              isListView: true,
              onTap: () => _openEntryDetails(entries[index]),
              onFavoriteToggle: () => _toggleFavorite(entries[index]),
            ),
          );
        },
      );
    }
  }

  Widget _buildCategoriesList() {
    if (_categories.isEmpty) {
      return _buildEmptyState(
        title: 'No Categories',
        subtitle: 'Categories will help organize your entries',
        icon: Icons.category_rounded,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final entryCount =
            _allEntries.where((e) => e.category == category.id).length;

        return Card(
          child: InkWell(
            onTap: () {
              // TODO: Open category view
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppHelpers.getEntryColor(category.color)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.iconName),
                      color: AppHelpers.getEntryColor(category.color),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$entryCount ${entryCount == 1 ? 'entry' : 'entries'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    String title = 'No Entries Yet',
    String subtitle = 'Tap the + button to add your first password entry',
    IconData icon = Icons.security_rounded,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                size: 50,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      default:
        return Icons.folder_rounded;
    }
  }

  void _openEntryDetails(PasswordEntry entry) {
    // TODO: Navigate to entry details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${entry.title}'),
        duration: const Duration(seconds: 1),
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
      builder: (context) => AlertDialog(
        title: const Text('Add New Entry'),
        content:
            const Text('Entry creation will be implemented in the next phase.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
