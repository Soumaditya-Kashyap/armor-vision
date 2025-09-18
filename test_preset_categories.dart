import 'package:flutter/material.dart';
import 'package:armor/services/database_service.dart';
import 'package:armor/models/password_entry.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preset Categories Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      // Initialize database (this will create preset categories)
      await _databaseService.initialize();

      // Load all categories
      final categories = await _databaseService.getAllCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preset Categories Test')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preset Categories (${_categories.length}):',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              _getIconData(category.iconName),
                              color: _getColorFromEntryColor(category.color),
                            ),
                            title: Text(category.name),
                            subtitle: Text(category.description ?? ''),
                            trailing: Chip(
                              label: Text('Sort: ${category.sortOrder}'),
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'lock':
        return Icons.lock;
      case 'email':
        return Icons.email;
      case 'work':
        return Icons.work;
      case 'people':
        return Icons.people;
      case 'account_balance':
        return Icons.account_balance;
      case 'movie':
        return Icons.movie;
      case 'shopping_cart':
        return Icons.shopping_cart;
      default:
        return Icons.folder;
    }
  }

  Color _getColorFromEntryColor(EntryColor entryColor) {
    switch (entryColor) {
      case EntryColor.blue:
        return Colors.blue;
      case EntryColor.red:
        return Colors.red;
      case EntryColor.green:
        return Colors.green;
      case EntryColor.indigo:
        return Colors.indigo;
      case EntryColor.orange:
        return Colors.orange;
      case EntryColor.purple:
        return Colors.purple;
      case EntryColor.amber:
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
