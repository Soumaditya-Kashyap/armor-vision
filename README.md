# ARMOR — Offline Password Manager

> **Open-source · Zero cloud · AES-256 encrypted · Built with Flutter**

ARMOR is a privacy-first, fully offline password manager built for Android. Every piece of data stays on your device, encrypted with AES-256. There is no cloud sync, no server, no account, no telemetry. Your vault is yours alone.

---

## Table of Contents

1. [What the App Does](#1-what-the-app-does)
2. [How the App Works — End to End](#2-how-the-app-works--end-to-end)
3. [Screens & Navigation Flow](#3-screens--navigation-flow)
4. [Key Features in Detail](#4-key-features-in-detail)
5. [Data Models](#5-data-models)
6. [Services Layer](#6-services-layer)
7. [Project Structure](#7-project-structure)
8. [Tech Stack & Dependencies](#8-tech-stack--dependencies)
9. [Architecture Patterns](#9-architecture-patterns)
10. [Developer Setup](#10-developer-setup)
11. [Developer Info](#11-developer-info)

---

## 1. What the App Does

ARMOR lets you securely store, organize, and retrieve all your sensitive information — passwords, credit cards, PINs, bank details, secure notes, Wi-Fi credentials, and anything else — behind your phone's biometric lock. There is no master password to remember. Just fingerprint, Face ID, or device PIN.

Core promises:
- **No cloud** — data never leaves your device
- **No account** — no sign-up, no login to ARMOR itself
- **No ads, no subscription** — completely free
- **Open source** — full codebase is public and auditable
- **AES-256 encryption** — every entry encrypted before storage
- **Biometric auth** — uses your phone's own security hardware

---

## 2. How the App Works — End to End

### First Launch (Fresh Install)

```
App starts
  └─► main.dart initializes Hive DB
        └─► checks AppSettings.hasCompletedOnboarding
              ├─► false → OnboardingScreen (5-page concentric transition intro)
              │         └─► on complete → sets hasCompletedOnboarding=true → SplashScreen
              └─► true  → SplashScreen directly
```

### Every Subsequent Launch

```
SplashScreen
  ├─► initializes EncryptionService, AuthService, DatabaseService
  ├─► checks AuthService session validity (5-min timeout)
  │     ├─► session valid → HomeScreen (skips auth)
  │     └─► session expired → AuthScreen
  │           ├─► biometric prompt (fingerprint / Face ID)
  │           ├─► fallback: device PIN
  │           └─► on success → HomeScreen
  └─► if any service init fails → shows error state with retry option
```

### Inside the Vault (HomeScreen)

```
HomeScreen
  ├─► Tab: All Entries
  │     ├─► sorted list/grid of all PasswordEntry items
  │     ├─► search bar — filters by title, category, tags, field values
  │     ├─► sort options: alphabetical, date created, date modified, last accessed
  │     └─► long-press → selection mode → bulk delete
  ├─► Tab: Starred
  │     └─► only isFavorite=true entries
  └─► Tab: Categories
        └─► grid of Category cards → tap → CategoryEntriesScreen (filtered entries)
```

---

## 3. Screens & Navigation Flow

| Screen | File | Purpose |
|---|---|---|
| **Onboarding** | `screens/onboarding/onboarding_screen.dart` | 5-page feature intro, first launch only |
| **Splash** | `screens/splash_screen.dart` | Service init, loading animation, routing |
| **Auth** | `screens/auth/auth_screen.dart` | Biometric / PIN authentication |
| **Home** | `screens/home/home_screen.dart` | Main vault view (entries + categories) |
| **Category Selection** | `screens/category_selection/` | Manage & create categories |
| **Category Entries** | `screens/category_entries/` | All entries in a specific category |
| **Backup & Restore** | `screens/backup/backup_restore_screen.dart` | Create / restore .armor backups |
| **Settings** | `screens/settings/settings_screen.dart` | Theme, export, backup, about |
| **About** | `screens/settings/about_screen.dart` | App info, features, privacy promise |
| **Developer** | `screens/settings/developer_screen.dart` | Creator info & contact |

### Dialogs

| Dialog | Purpose |
|---|---|
| `add_entry_dialog.dart` | Create a new password entry with dynamic fields |
| `password_entry_detail_dialog.dart` | View / edit / delete an existing entry |
| `export_dialog.dart` | Configure PDF or .armor export |
| `export_progress_dialog.dart` | Step-by-step export progress |
| `export_success_dialog.dart` | Confirmation with file path |
| `set_default_password_dialog.dart` | Save a default export password |
| `icon_picker_dialog.dart` | Pick Iconsax icon for category |

---

## 4. Key Features in Detail

### Authentication
- Uses `local_auth` package — device biometrics (fingerprint, Face ID) or PIN
- Session token managed by `AuthService` — expires after **5 minutes** of inactivity
- **Max 5 failed attempts** → progressive lockout
- No separate ARMOR password — your phone IS the key

### Vault Entries (`PasswordEntry`)
- Each entry has: title, description, category (by ID), color, icon, tags
- **Dynamic custom fields** — each `CustomField` has a label, value, type (`text`, `password`, `email`, `url`, `phone`, `pin`, `note`), and `isHidden` flag
- Hidden fields shown/hidden with a tap — value revealed only on demand
- `accessCount` and `lastAccessedAt` tracked for "recently used" features
- `isFavorite` and `isArchived` flags
- Colors: `EntryColor` enum (blue, red, green, teal, purple, orange, pink, yellow, indigo, gray)

### Categories
- Default preset categories: General, Banking, Social Media, Email, Work, Shopping, Travel, Entertainment
- User can create unlimited custom categories with custom name, icon (Iconsax), and color
- Categories stored by **ID not name** — migration handles old data with names
- Deleted preset categories are tracked in a separate `deleted_categories` Hive box so they don't auto-restore on next launch

### Encryption
- `EncryptionService` uses AES-256 with a key stored in platform secure storage (`flutter_secure_storage` → Android Keystore / iOS Keychain)
- All sensitive field values encrypted before hitting Hive
- Export passwords also encrypted before being saved to AppSettings

### Backup — `.armor` File Format
- Proprietary encrypted archive format (`.armor` extension)
- Contains all vault entries + categories, encrypted with a master key you set
- Backed up to `/storage/emulated/0/Armor/Backups/`
- Android MediaStore is scanned after creation so files appear in file managers
- Restore: pick file via file picker → enter master key → data imported
- `BackupService` handles creation, listing, and restoration
- `WidgetsBindingObserver` in `BackupRestoreScreen` triggers refresh when returning from file manager

### PDF Export
- Generates a formatted PDF of all entries using `pdf` + `syncfusion_flutter_pdf`
- PDF saved to `/storage/emulated/0/Armor/PDFs/`
- Password-protected before saving
- Shared via `share_plus`
- Export dialog lets you choose format (PDF vs .armor), set password, or use a saved default password

### Themes
- 4 modes: **Light**, **Dark**, **Armor** (aurora-style gradient tones), **System**
- Managed by `ThemeProvider` (Provider pattern) — singleton, `ChangeNotifierProvider.value` in `main.dart`
- Each theme is defined in `utils/armor_themes.dart` as a full `ThemeData` with M3 color schemes
- Font: **Bricolage Grotesque** via Google Fonts
- Persists to Hive via `AppSettings.themeMode`

### Onboarding
- 5 screens with concentric circle page transitions (`concentric_transition` package)
- Each page has a vibrant background color — the expanding circle IS the next page's color
- Pages: Privacy/No Cloud (blue) → Biometric Auth (green) → Categories & Vault (purple) → Backup (crimson) → Enter ARMOR (midnight)
- State saved in `AppSettings.hasCompletedOnboarding` (nullable `bool?` for backward compat)
- Skip button on all pages except last; "ENTER ARMOR" hint above the final button

---

## 5. Data Models

### `PasswordEntry` (typeId: 1)

```dart
String id                  // UUID
String title
String description
String category            // Category ID (not name)
List<String> tags
EntryColor color
String? iconName           // Iconsax icon name string
bool isFavorite
bool isArchived
List<CustomField> customFields
int accessCount
DateTime? lastAccessedAt
DateTime createdAt
DateTime updatedAt
```

### `CustomField` (typeId: 2)

```dart
String label
String value              // stored encrypted
FieldType type            // text, password, email, url, phone, pin, note
bool isHidden
```

### `Category` (typeId: 3)

```dart
String id
String name
String iconName
EntryColor color
int sortOrder
bool isPreset
DateTime createdAt
```

### `AppSettings` (typeId: 5)

```dart
bool isDarkMode
bool isBiometricEnabled
int autoLockTimeoutMinutes        // default: 5
bool isFirstLaunch
String defaultCategory
SortOption defaultSortOption
ViewMode defaultViewMode          // grid, list, compact
bool showPasswordStrength
bool enableAutoBackup
int maxBackupFiles
bool showRecentlyUsed
bool enableSearchHistory
bool showTips
String language
bool enableHapticFeedback
SecurityLevel securityLevel       // standard, high, maximum
DateTime? lastBackupAt
int totalEntries
DateTime createdAt
DateTime updatedAt
ArmorThemeMode themeMode
String? defaultExportPassword     // AES encrypted
String? preferredExportFormat
DateTime? lastExportDate
bool? hasCompletedOnboarding      // nullable for backward compat
```

### Enums

| Enum | typeId | Values |
|---|---|---|
| `FieldType` | 4 | text, password, email, url, phone, pin, note |
| `SortOption` | 6 | alphabetical, dateCreated, dateModified, lastAccessed, category, favorite |
| `ViewMode` | 7 | grid, list, compact |
| `SecurityLevel` | 8 | standard, high, maximum |
| `EntryColor` | 9 | blue, red, green, teal, purple, orange, pink, yellow, indigo, gray |
| `ArmorThemeMode` | 10 | light, dark, armor, system |

---

## 6. Services Layer

### `DatabaseService` (singleton)

Central data access layer. Always call `initialize()` before use (done in `main()`).

Key methods:
```dart
initialize()                          // opens all Hive boxes, runs migrations
getAllPasswordEntries({includeArchived})
savePasswordEntry(entry)
deletePasswordEntry(id)
getAllCategories()                     // sorted by sortOrder
saveCategory(category)
deleteCategory(id)                    // marks in deleted_categories box
getAppSettings()
saveAppSettings(settings)
createSampleData()                    // testing only
```

Hive boxes used:
- `password_entries` — all vault entries
- `categories` — user and preset categories
- `settings` — single `AppSettings` object keyed `'default'`
- `deleted_categories` — IDs of manually deleted preset categories

Migration: `_migrateCategoryNamesToIds()` runs on init to convert old entries that stored category name (string) instead of category ID.

### `AuthService`

```dart
checkDeviceSecurityStatus()           // biometric capability, device lock status
authenticateWithBiometrics()          // calls local_auth
isSessionValid()                      // checks 5-min timeout
refreshSession()
clearSession()
```

### `EncryptionService`

```dart
initialize()                          // generates/loads AES key from secure storage
encrypt(plaintext) → String
decrypt(ciphertext) → String
generatePassword({length, options})   // random password generator
```

### `BackupService`

```dart
createBackup(masterKey) → BackupResult
restoreBackup(filePath, masterKey) → RestoreResult
listBackups() → List<BackupFileInfo>
deleteBackup(path)
```

Storage path: `/storage/emulated/0/Armor/Backups/`
Platform channel: `com.example.armor/media_scanner` → `MainActivity.kt` scans new files into MediaStore

### `ExportPasswordService`

```dart
exportPasswords(ExportConfig) → ExportResult
```

Storage path: `/storage/emulated/0/Armor/PDFs/`
Same MediaStore scanning pattern as BackupService.

---

## 7. Project Structure

```
lib/
├── main.dart                          # Entry point, DB init, onboarding check, theme setup
├── models/
│   ├── password_entry.dart            # PasswordEntry, CustomField, Category, FieldType, EntryColor
│   ├── password_entry.g.dart          # Generated Hive adapter
│   ├── app_settings.dart              # AppSettings + enums (SortOption, ViewMode, etc.)
│   ├── app_settings.g.dart            # Generated Hive adapter
│   └── export_models.dart             # ExportConfig, ExportResult, BackupFileInfo
├── providers/
│   └── theme_provider.dart            # ChangeNotifier, setThemeMode(), persists to Hive
├── services/
│   ├── database_service.dart          # Hive CRUD, migrations, singleton
│   ├── auth_service.dart              # Biometric auth, session management
│   ├── encryption_service.dart        # AES-256, key management via flutter_secure_storage
│   ├── backup_service.dart            # .armor file create/restore, MediaStore scan
│   └── export_password_service.dart   # PDF export, MediaStore scan
├── screens/
│   ├── splash_screen.dart             # Loading, service init, route decision
│   ├── onboarding/
│   │   └── onboarding_screen.dart     # 5-page concentric transition intro
│   ├── auth/
│   │   └── auth_screen.dart           # Biometric / PIN unlock
│   ├── home/
│   │   ├── home_screen.dart           # Main vault coordinator
│   │   └── components/
│   │       ├── home_app_bar.dart
│   │       ├── home_search_bar.dart
│   │       ├── home_tab_bar.dart
│   │       ├── entries_list.dart
│   │       └── categories_grid.dart
│   ├── category_selection/
│   │   ├── category_selection_screen.dart
│   │   └── components/
│   │       ├── category_selection_header.dart
│   │       ├── category_grid.dart
│   │       └── category_action_buttons.dart
│   ├── category_entries/
│   │   └── category_entries_screen.dart
│   ├── backup/
│   │   └── backup_restore_screen.dart
│   └── settings/
│       ├── settings_screen.dart
│       ├── about_screen.dart
│       ├── developer_screen.dart
│       └── components/
│           ├── section_header.dart
│           ├── theme_selector.dart
│           ├── theme_options_grid.dart
│           ├── theme_card.dart
│           ├── current_theme_display.dart
│           ├── secure_export_card.dart
│           ├── backup_restore_card.dart
│           └── coming_soon_card.dart
├── widgets/
│   └── dialogs/
│       ├── add_entry_dialog.dart
│       ├── password_entry_detail_dialog.dart
│       ├── export_dialog.dart
│       ├── export_progress_dialog.dart
│       ├── export_success_dialog.dart
│       ├── set_default_password_dialog.dart
│       ├── components/                # Form fields, color selector
│       └── detail_components/        # Entry header, info sections
└── utils/
    ├── armor_themes.dart              # ThemeData for all 4 modes
    ├── constants.dart                 # App-wide constants
    ├── icon_helper.dart               # IconData from string name (Iconsax)
    └── app_helpers.dart               # Category icon helpers

android/
└── app/src/main/
    ├── kotlin/com/example/armor/
    │   └── MainActivity.kt            # MethodChannel: media_scanner
    └── AndroidManifest.xml            # MANAGE_EXTERNAL_STORAGE permission
```

---

## 8. Tech Stack & Dependencies

| Package | Version | Use |
|---|---|---|
| `flutter` | SDK | UI framework |
| `hive` + `hive_flutter` | ^2.2.3 | Local NoSQL database |
| `encrypt` | ^5.0.3 | AES-256 encryption |
| `flutter_secure_storage` | ^9.2.4 | Platform keychain/keystore for encryption key |
| `local_auth` | ^2.3.0 | Biometric / device auth |
| `provider` | ^6.1.2 | Theme state management |
| `google_fonts` | ^6.2.1 | Bricolage Grotesque font |
| `iconsax` | ^0.0.8 | Primary icon library |
| `pdf` | ^3.11.3 | PDF generation |
| `syncfusion_flutter_pdf` | ^31.2.5 | Advanced PDF features |
| `printing` | ^5.14.2 | PDF printing/sharing |
| `share_plus` | ^12.0.1 | Share exported files |
| `file_picker` | ^10.3.3 | Pick .armor files for restore |
| `permission_handler` | ^12.0.1 | Storage permissions |
| `path_provider` | ^2.1.5 | App document directory |
| `archive` | ^4.0.7 | File archiving for .armor format |
| `lottie` | ^3.3.2 | Lottie animations (splash) |
| `concentric_transition` | ^1.0.3 | Onboarding page transitions |
| `intl` | ^0.19.0 | Date formatting |
| `crypto` | ^3.0.6 | Hashing |
| `image_picker` | ^1.2.0 | (reserved for future avatar/image fields) |
| `flutter_staggered_grid_view` | ^0.7.0 | Staggered entry grid layout |

**Dev dependencies:**
- `hive_generator` — generates type adapters
- `build_runner` — code generation
- `flutter_lints` — lint rules
- `flutter_launcher_icons` — app icon generation

---

## 9. Architecture Patterns

### State Management
- **Theme:** `ThemeProvider` (ChangeNotifier+Provider) — only global state
- **Screens:** Local `StatefulWidget` state for all UI interactions
- **Business logic:** Methods on screen classes, not separate blocs/cubits

### Component Architecture
Screens are coordinators (state + logic), components are presentational (props down, callbacks up):

```dart
HomeScreen                    // manages state, passes callbacks
  └── EntriesList             // displays list, fires events up
  └── CategoriesGrid          // displays grid, fires events up
  └── HomeAppBar              // displays bar, fires button events up
  └── HomeSearchBar           // emits search query up
  └── HomeTabBar              // emits tab index up
```

Target: **100–150 lines per component file.** Flag for extraction if > 250 lines.

### Data Flow
```
UI Widget
  ├─► calls DatabaseService method
  ├─► gets model back
  ├─► calls setState()
  └─► widget rebuilds with new data
```

No reactive streams — all DB calls are `async/await` with explicit `setState`.

### Singleton Services
```dart
DatabaseService db = DatabaseService();  // same instance anywhere
AuthService auth = AuthService();
EncryptionService enc = EncryptionService();
BackupService backup = BackupService();
```

### Hive Type IDs (must never change)

| typeId | Class |
|---|---|
| 1 | PasswordEntry |
| 2 | CustomField |
| 3 | Category |
| 4 | FieldType |
| 5 | AppSettings |
| 6 | SortOption |
| 7 | ViewMode |
| 8 | SecurityLevel |
| 9 | EntryColor |
| 10 | ArmorThemeMode |

---

## 10. Developer Setup

### Prerequisites
- Flutter SDK (tested on 3.11.0+)
- Dart SDK ^3.9.0
- Android Studio / VS Code
- Android device or emulator (Android 6.0+ for biometrics)

### Run the App

```bash
# Quick start (Windows)
dev.bat

# Manual
flutter pub get
flutter run

# Specific device
flutter devices                  # list connected devices
flutter run -d <device-id>

# Hot reload → r
# Hot restart → R
# Quit → q
```

### After Modifying Hive Models

**Important:** Any change to a `@HiveType` class or `@HiveField` annotation requires regeneration:

```bash
dart run build_runner build --delete-conflicting-outputs

# Watch mode during development
dart run build_runner watch --delete-conflicting-outputs
```

Rules:
- Never change an existing `typeId`
- Never change an existing `@HiveField(N)` number — only add new ones at the end
- Use `bool?` (nullable) for new boolean fields to avoid crashes on existing data

### Storage Paths (Android)

```
/storage/emulated/0/
└── Armor/
    ├── Backups/     ← encrypted .armor files
    └── PDFs/        ← exported PDFs
```

### Known Quirks

1. **Category ID vs Name** — always use `category.id`, never `category.name`. Old entries with names get migrated on `DatabaseService.initialize()`.
2. **Nullable booleans in AppSettings** — `hasCompletedOnboarding` is `bool?` to handle installs that existed before this field. Always use `?? false` when reading.
3. **MediaStore scanning** — after writing a file to external storage, call the `com.example.armor/media_scanner` platform channel or the file won't appear in file managers.
4. **Hot reload safe** — all screens survive hot reload. Hive adapter changes require full restart.
5. **Session timeout** — `AuthService` checks timestamp on each `HomeScreen` navigation. After 5 min of app background, auth screen is shown again.

---

## 11. Developer Info

**Soumaditya Kashyap**
Guwahati, Assam, India

- GitHub: https://github.com/Soumaditya-Kashyap
- LinkedIn: https://www.linkedin.com/in/soumaditya-kashyap-27689b204
- Email: officialsoumaditya@gmail.com

ARMOR is an open-source project. Issues, PRs, and feedback are welcome.

---

*Version 1.0.0 · Built with Flutter · MIT License*

