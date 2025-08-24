import 'package:hive_flutter/hive_flutter.dart';
import '../models/password_entry.dart';
import '../models/app_settings.dart';
import 'encryption_service.dart';

class DatabaseService {
  static const String _entriesBoxName = 'password_entries';
  static const String _settingsBoxName = 'app_settings';
  static const String _categoriesBoxName = 'categories';

  late Box<PasswordEntry> _entriesBox;
  late Box<AppSettings> _settingsBox;
  late Box<Category> _categoriesBox;

  final EncryptionService _encryptionService = EncryptionService();
  bool _isInitialized = false;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Initialize database
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(PasswordEntryAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CustomFieldAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(FieldTypeAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(EntryColorAdapter());
      }
      if (!Hive.isAdapterRegistered(4)) {
        Hive.registerAdapter(CategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(AppSettingsAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(SortOptionAdapter());
      }
      if (!Hive.isAdapterRegistered(7)) {
        Hive.registerAdapter(ViewModeAdapter());
      }
      if (!Hive.isAdapterRegistered(8)) {
        Hive.registerAdapter(SecurityLevelAdapter());
      }

      // Initialize encryption service
      await _encryptionService.initialize();

      // Open boxes
      _entriesBox = await Hive.openBox<PasswordEntry>(_entriesBoxName);
      _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
      _categoriesBox = await Hive.openBox<Category>(_categoriesBoxName);

      // Initialize default data
      await _initializeDefaults();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  /// Initialize default data
  Future<void> _initializeDefaults() async {
    // Initialize settings if not exists
    if (_settingsBox.isEmpty) {
      final settings = AppSettings(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _settingsBox.put('default', settings);
    }

    // Initialize default categories if not exists
    if (_categoriesBox.isEmpty) {
      await _createDefaultCategories();
    }
  }

  /// Create default categories
  Future<void> _createDefaultCategories() async {
    final defaultCategories = [
      Category(
        id: 'general',
        name: 'General',
        description: 'General accounts and services',
        color: EntryColor.blue,
        iconName: 'account_circle',
        createdAt: DateTime.now(),
        sortOrder: 0,
      ),
      Category(
        id: 'social',
        name: 'Social Media',
        description: 'Social media accounts',
        color: EntryColor.purple,
        iconName: 'people',
        createdAt: DateTime.now(),
        sortOrder: 1,
      ),
      Category(
        id: 'banking',
        name: 'Banking',
        description: 'Banking and financial accounts',
        color: EntryColor.green,
        iconName: 'account_balance',
        createdAt: DateTime.now(),
        sortOrder: 2,
      ),
    ];

    for (final category in defaultCategories) {
      await _categoriesBox.put(category.id, category);
    }
  }

  /// Save password entry
  Future<void> savePasswordEntry(PasswordEntry entry) async {
    await _entriesBox.put(entry.id, entry);
  }

  /// Get all password entries
  Future<List<PasswordEntry>> getAllPasswordEntries() async {
    return _entriesBox.values.toList();
  }

  /// Get password entry by ID
  Future<PasswordEntry?> getPasswordEntry(String id) async {
    return _entriesBox.get(id);
  }

  /// Delete password entry
  Future<void> deletePasswordEntry(String id) async {
    await _entriesBox.delete(id);
  }

  /// Get all categories
  Future<List<Category>> getAllCategories() async {
    final categories = _categoriesBox.values.toList();
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return categories;
  }

  /// Get app settings
  Future<AppSettings> getAppSettings() async {
    final settings = _settingsBox.get('default');
    if (settings == null) {
      final defaultSettings = AppSettings(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _settingsBox.put('default', defaultSettings);
      return defaultSettings;
    }
    return settings;
  }

  /// Save app settings
  Future<void> saveAppSettings(AppSettings settings) async {
    await _settingsBox.put('default', settings);
  }

  /// Close database
  Future<void> close() async {
    if (_isInitialized) {
      await _entriesBox.close();
      await _settingsBox.close();
      await _categoriesBox.close();
      _isInitialized = false;
    }
  }

  /// Create sample data for testing
  Future<void> createSampleData() async {
    // Check if we already have data
    if (_entriesBox.isNotEmpty) return;

    // Create sample categories first
    final sampleCategories = [
      Category(
        id: 'social',
        name: 'Social Media',
        description: 'Social media accounts',
        iconName: 'people',
        color: EntryColor.blue,
        sortOrder: 1,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'work',
        name: 'Work',
        description: 'Work-related accounts',
        iconName: 'work',
        color: EntryColor.green,
        sortOrder: 2,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'banking',
        name: 'Banking',
        description: 'Financial accounts',
        iconName: 'account_balance',
        color: EntryColor.red,
        sortOrder: 3,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        description: 'Shopping accounts',
        iconName: 'shopping_cart',
        color: EntryColor.amber,
        sortOrder: 4,
        createdAt: DateTime.now(),
      ),
      Category(
        id: 'entertainment',
        name: 'Entertainment',
        description: 'Entertainment accounts',
        iconName: 'movie',
        color: EntryColor.orange,
        sortOrder: 5,
        createdAt: DateTime.now(),
      ),
    ];

    for (final category in sampleCategories) {
      await _categoriesBox.put(category.id, category);
    }

    // Create sample password entries
    final sampleEntries = [
      PasswordEntry(
        id: 'entry_1',
        title: 'Gmail',
        description: 'Personal email account',
        category: 'social',
        tags: ['email', 'personal'],
        color: EntryColor.blue,
        isFavorite: true,
        customFields: [
          CustomField(
            label: 'Email',
            value: 'john.doe@gmail.com',
            type: FieldType.email,
            isRequired: true,
            isHidden: false,
          ),
          CustomField(
            label: 'Password',
            value: 'MySecurePassword123!',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
          CustomField(
            label: 'Recovery Email',
            value: 'john.recovery@gmail.com',
            type: FieldType.email,
            isRequired: false,
            isHidden: false,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      PasswordEntry(
        id: 'entry_2',
        title: 'Facebook',
        description: 'Social media account',
        category: 'social',
        tags: ['social', 'personal'],
        color: EntryColor.indigo,
        isFavorite: false,
        customFields: [
          CustomField(
            label: 'Username',
            value: 'john.doe.fb',
            type: FieldType.username,
            isRequired: true,
            isHidden: false,
          ),
          CustomField(
            label: 'Password',
            value: 'FacebookPass456!',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      PasswordEntry(
        id: 'entry_3',
        title: 'Company Portal',
        description: 'Work email and portal access',
        category: 'work',
        tags: ['work', 'corporate'],
        color: EntryColor.green,
        isFavorite: true,
        customFields: [
          CustomField(
            label: 'Employee ID',
            value: 'EMP001234',
            type: FieldType.text,
            isRequired: true,
            isHidden: false,
          ),
          CustomField(
            label: 'Email',
            value: 'john.doe@company.com',
            type: FieldType.email,
            isRequired: true,
            isHidden: false,
          ),
          CustomField(
            label: 'Password',
            value: 'WorkSecure789!',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
          CustomField(
            label: 'VPN Access',
            value: 'vpn.company.com',
            type: FieldType.url,
            isRequired: false,
            isHidden: false,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PasswordEntry(
        id: 'entry_4',
        title: 'Chase Bank',
        description: 'Primary checking account',
        category: 'banking',
        tags: ['banking', 'finance'],
        color: EntryColor.red,
        isFavorite: true,
        customFields: [
          CustomField(
            label: 'Username',
            value: 'johndoe123',
            type: FieldType.username,
            isRequired: true,
            isHidden: false,
          ),
          CustomField(
            label: 'Password',
            value: 'BankSecure999!',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
          CustomField(
            label: 'Account Number',
            value: '1234567890',
            type: FieldType.bankAccount,
            isRequired: true,
            isHidden: true,
          ),
          CustomField(
            label: 'Routing Number',
            value: '021000021',
            type: FieldType.number,
            isRequired: true,
            isHidden: false,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PasswordEntry(
        id: 'entry_5',
        title: 'Netflix',
        description: 'Streaming service account',
        category: 'entertainment',
        tags: ['streaming', 'entertainment'],
        color: EntryColor.orange,
        isFavorite: false,
        customFields: [
          CustomField(
            label: 'Email',
            value: 'john.doe@gmail.com',
            type: FieldType.email,
            isRequired: true,
            isHidden: false,
          ),
          CustomField(
            label: 'Password',
            value: 'NetflixPass321!',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
          CustomField(
            label: 'Profile PIN',
            value: '1234',
            type: FieldType.pin,
            isRequired: false,
            isHidden: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      PasswordEntry(
        id: 'entry_6',
        title: 'Amazon',
        description: 'Shopping and Prime account',
        category: 'shopping',
        tags: ['shopping', 'prime'],
        color: EntryColor.amber,
        isFavorite: true,
        customFields: [
          CustomField(
            label: 'Email',
            value: 'john.doe@gmail.com',
            type: FieldType.email,
            isRequired: true,
            isHidden: false,
          ),
          CustomField(
            label: 'Password',
            value: 'AmazonSecure654!',
            type: FieldType.password,
            isRequired: true,
            isHidden: true,
          ),
          CustomField(
            label: 'Credit Card',
            value: '**** **** **** 1234',
            type: FieldType.creditCard,
            isRequired: false,
            isHidden: true,
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    for (final entry in sampleEntries) {
      await savePasswordEntry(entry);
    }
  }

  // Getters
  bool get isInitialized => _isInitialized;
  int get totalEntries => _entriesBox.length;
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
