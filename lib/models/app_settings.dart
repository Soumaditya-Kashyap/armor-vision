import 'package:hive/hive.dart';
import '../utils/armor_themes.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 5)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool isBiometricEnabled;

  @HiveField(2)
  int autoLockTimeoutMinutes;

  @HiveField(3)
  bool isFirstLaunch;

  @HiveField(4)
  String defaultCategory;

  @HiveField(5)
  SortOption defaultSortOption;

  @HiveField(6)
  ViewMode defaultViewMode;

  @HiveField(7)
  bool showPasswordStrength;

  @HiveField(8)
  bool enableAutoBackup;

  @HiveField(9)
  int maxBackupFiles;

  @HiveField(10)
  bool showRecentlyUsed;

  @HiveField(11)
  bool enableSearchHistory;

  @HiveField(12)
  bool showTips;

  @HiveField(13)
  String language;

  @HiveField(14)
  bool enableHapticFeedback;

  @HiveField(15)
  SecurityLevel securityLevel;

  @HiveField(16)
  DateTime? lastBackupAt;

  @HiveField(17)
  int totalEntries;

  @HiveField(18)
  DateTime createdAt;

  @HiveField(19)
  DateTime updatedAt;

  @HiveField(20)
  ArmorThemeMode? themeMode;

  @HiveField(21)
  String? defaultExportPassword;

  @HiveField(22)
  String? preferredExportFormat;

  @HiveField(23)
  DateTime? lastExportDate;

  AppSettings({
    this.isDarkMode = false,
    this.isBiometricEnabled = true,
    this.autoLockTimeoutMinutes = 5,
    this.isFirstLaunch = true,
    this.defaultCategory = 'general',
    this.defaultSortOption = SortOption.dateModified,
    this.defaultViewMode = ViewMode.grid,
    this.showPasswordStrength = true,
    this.enableAutoBackup = false,
    this.maxBackupFiles = 5,
    this.showRecentlyUsed = true,
    this.enableSearchHistory = true,
    this.showTips = true,
    this.language = 'en',
    this.enableHapticFeedback = true,
    this.securityLevel = SecurityLevel.high,
    this.lastBackupAt,
    this.totalEntries = 0,
    required this.createdAt,
    required this.updatedAt,
    this.themeMode,
    this.defaultExportPassword,
    this.preferredExportFormat,
    this.lastExportDate,
  });

  // Getter to provide a default theme mode
  ArmorThemeMode get effectiveThemeMode => themeMode ?? ArmorThemeMode.system;

  AppSettings copyWith({
    bool? isDarkMode,
    bool? isBiometricEnabled,
    int? autoLockTimeoutMinutes,
    bool? isFirstLaunch,
    String? defaultCategory,
    SortOption? defaultSortOption,
    ViewMode? defaultViewMode,
    bool? showPasswordStrength,
    bool? enableAutoBackup,
    int? maxBackupFiles,
    bool? showRecentlyUsed,
    bool? enableSearchHistory,
    bool? showTips,
    String? language,
    bool? enableHapticFeedback,
    SecurityLevel? securityLevel,
    DateTime? lastBackupAt,
    int? totalEntries,
    DateTime? createdAt,
    DateTime? updatedAt,
    ArmorThemeMode? themeMode,
    String? defaultExportPassword,
    String? preferredExportFormat,
    DateTime? lastExportDate,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      autoLockTimeoutMinutes:
          autoLockTimeoutMinutes ?? this.autoLockTimeoutMinutes,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      defaultSortOption: defaultSortOption ?? this.defaultSortOption,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      showPasswordStrength: showPasswordStrength ?? this.showPasswordStrength,
      enableAutoBackup: enableAutoBackup ?? this.enableAutoBackup,
      maxBackupFiles: maxBackupFiles ?? this.maxBackupFiles,
      showRecentlyUsed: showRecentlyUsed ?? this.showRecentlyUsed,
      enableSearchHistory: enableSearchHistory ?? this.enableSearchHistory,
      showTips: showTips ?? this.showTips,
      language: language ?? this.language,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      securityLevel: securityLevel ?? this.securityLevel,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      totalEntries: totalEntries ?? this.totalEntries,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      themeMode: themeMode ?? this.themeMode,
      defaultExportPassword:
          defaultExportPassword ?? this.defaultExportPassword,
      preferredExportFormat:
          preferredExportFormat ?? this.preferredExportFormat,
      lastExportDate: lastExportDate ?? this.lastExportDate,
    );
  }
}

@HiveType(typeId: 6)
enum SortOption {
  @HiveField(0)
  alphabetical,

  @HiveField(1)
  dateCreated,

  @HiveField(2)
  dateModified,

  @HiveField(3)
  lastAccessed,

  @HiveField(4)
  category,

  @HiveField(5)
  favorite,
}

@HiveType(typeId: 7)
enum ViewMode {
  @HiveField(0)
  grid,

  @HiveField(1)
  list,

  @HiveField(2)
  compact,
}

@HiveType(typeId: 8)
enum SecurityLevel {
  @HiveField(0)
  standard,

  @HiveField(1)
  high,

  @HiveField(2)
  maximum,
}
