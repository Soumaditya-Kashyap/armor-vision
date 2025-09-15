import 'package:flutter/material.dart';
import '../../models/password_entry.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';
import '../../widgets/password_entry_card.dart';
import '../../widgets/dialogs/add_entry_dialog.dart';

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
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Armor',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${_allEntries.length} entries',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'More view options coming soon!',
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.view_module_rounded,
                                size: 18,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: colorScheme.outline.withOpacity(0.3),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/settings');
                              },
                              icon: const Icon(
                                Icons.settings_rounded,
                                size: 18,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search your vault...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Bar
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSimpleTab(
                            'All',
                            _filteredEntries.length,
                            Icons.all_inclusive_rounded,
                            0,
                          ),
                        ),
                        Expanded(
                          child: _buildSimpleTab(
                            'Favorites',
                            _filteredFavorites.length,
                            Icons.favorite_rounded,
                            1,
                          ),
                        ),
                        Expanded(
                          child: _buildSimpleTab(
                            'Categories',
                            _categories.length,
                            Icons.category_rounded,
                            2,
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
                  : IndexedStack(
                      index: _currentTabIndex,
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
        label: const Text('Add Entry'),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSimpleTab(String label, int count, IconData icon, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.onPrimary.withOpacity(0.2)
                        : colorScheme.onSurfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntriesList(List<PasswordEntry> entries) {
    if (entries.isEmpty) {
      // Check which tab we're on for different empty states
      if (_currentTabIndex == 1) {
        return _buildEmptyState(
          title: 'No Favorites Yet',
          subtitle:
              'Mark your most important passwords as favorites by tapping the heart icon. They\'ll appear here for quick access.',
          icon: Icons.favorite_outline_rounded,
        );
      }
      return _buildEmptyState();
    }

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

  Widget _buildCategoriesList() {
    if (_categories.isEmpty) {
      return _buildEmptyState(
        title: 'No Categories Yet',
        subtitle:
            'Categories help organize your password entries. Default categories will be created when you add your first entry.',
        icon: Icons.category_outlined,
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
        final entryCount = _allEntries
            .where((e) => e.category == category.id)
            .length;

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
                      color: AppHelpers.getEntryColor(
                        category.color,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.iconName),
                      color: AppHelpers.getEntryColor(category.color),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: Text(
                      '$entryCount ${entryCount == 1 ? 'entry' : 'entries'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
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
    String title = 'Your Vault is Empty',
    String subtitle =
        'Start securing your digital life by adding your first password entry. Tap the "Add Entry" button below to get started!',
    IconData icon = Icons.lock_outline_rounded,
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 60,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
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
      barrierDismissible: false,
      builder: (context) => AddEntryDialog(
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
