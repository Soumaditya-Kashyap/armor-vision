# Category Deletion Persistence Fix

## Issue
When users deleted categories (both default preset categories and custom categories), they would reappear after hot restart or app reopen. This happened because the `_ensurePresetCategories()` method would re-create any missing preset categories on every app initialization.

## Root Cause
The initialization logic checked if a preset category existed in the database:
- If **NOT found** → Add it back (assuming it was never created)
- If **found** → Update icon if needed

This logic couldn't distinguish between:
1. A category that was never created (fresh install)
2. A category that was explicitly deleted by the user

## Solution
Implemented a **deleted categories tracking system** using a separate Hive box.

### Changes Made

#### 1. Added Deleted Categories Box
**File**: `lib/services/database_service.dart`

```dart
// New box to track deleted category IDs
static const String _deletedCategoriesBoxName = 'deleted_categories';
late Box<String> _deletedCategoriesBox;
```

**Purpose**: Stores the IDs of categories that have been explicitly deleted by users.

#### 2. Initialize Deleted Categories Box
```dart
_deletedCategoriesBox = await Hive.openBox<String>(_deletedCategoriesBoxName);
```

Opens the box during database initialization.

#### 3. Updated Category Deletion Logic
```dart
Future<void> deleteCategory(String categoryId) async {
  _ensureInitialized();
  try {
    // Delete the category
    await _categoriesBox.delete(categoryId);
    
    // Mark as deleted so it won't be re-created on app restart
    await _deletedCategoriesBox.put(categoryId, categoryId);
  } catch (e) {
    throw DatabaseException('Failed to delete category: $e');
  }
}
```

**What it does**:
1. Deletes the category from the categories box
2. Adds the category ID to the deleted categories box
3. This creates a permanent record that the user deleted this category

#### 4. Updated Preset Categories Initialization
```dart
Future<void> _ensurePresetCategories() async {
  final presetCategories = _getPresetCategories();

  for (final presetCategory in presetCategories) {
    // Skip if this category was explicitly deleted by user
    if (_deletedCategoriesBox.containsKey(presetCategory.id)) {
      continue; // Don't re-create deleted categories
    }

    // Check if this preset category already exists
    final existingCategory = _categoriesBox.get(presetCategory.id);
    if (existingCategory == null) {
      // Add missing preset category (only if not deleted before)
      await _categoriesBox.put(presetCategory.id, presetCategory);
    } else {
      // Update existing preset category's icon if it's different
      if (existingCategory.iconName != presetCategory.iconName) {
        final updatedCategory = existingCategory.copyWith(
          iconName: presetCategory.iconName,
        );
        await _categoriesBox.put(presetCategory.id, updatedCategory);
      }
    }
  }
}
```

**What changed**:
- Added check: `if (_deletedCategoriesBox.containsKey(presetCategory.id))`
- If a category ID is in the deleted box → Skip it completely
- This prevents re-creating categories that users have explicitly removed

## How It Works

### Scenario 1: Fresh Install
```
App Install
    ↓
Initialize Database
    ↓
Check deleted categories box → Empty
    ↓
Create all preset categories (General, Gmail, Work, Social, Banking, etc.)
```

### Scenario 2: User Deletes a Category
```
User selects "Banking" category
    ↓
Taps "Delete (1)"
    ↓
Confirms deletion
    ↓
deleteCategory("banking") called
    ↓
1. Remove from categories box
2. Add "banking" to deleted_categories box
    ↓
Category removed from UI
```

### Scenario 3: App Restart After Deletion
```
App Restart
    ↓
Initialize Database
    ↓
_ensurePresetCategories() runs
    ↓
For each preset category:
  - Check if in deleted_categories box
  - "banking" found in deleted box → SKIP
  - Other categories not deleted → Ensure they exist
    ↓
"Banking" category stays deleted ✅
```

### Scenario 4: App Uninstall/Reinstall
```
Uninstall App
    ↓
All Hive boxes deleted (including deleted_categories)
    ↓
Reinstall App
    ↓
deleted_categories box is empty
    ↓
All preset categories created again (fresh start)
```

## Benefits

### User Experience
✅ **Persistent Deletions**: Deleted categories stay deleted  
✅ **User Control**: Respects user's choice to remove categories  
✅ **Clean UI**: No unwanted categories reappearing  
✅ **Fresh Install**: Uninstall/reinstall gives default categories back  

### Technical
✅ **Lightweight**: Only stores category IDs (strings)  
✅ **Fast Lookup**: O(1) containsKey check  
✅ **Persistent**: Survives hot restarts, app closes, device reboots  
✅ **Safe**: Separate box means no conflicts with category data  

## Database Structure

### Categories Box (`categories`)
Stores active categories:
```dart
{
  'general': Category(id: 'general', name: 'General', ...),
  'social': Category(id: 'social', name: 'Social Media', ...),
  'work': Category(id: 'work', name: 'Work', ...),
  // etc.
}
```

### Deleted Categories Box (`deleted_categories`)
Stores IDs of deleted categories:
```dart
{
  'banking': 'banking',        // User deleted Banking
  'entertainment': 'entertainment',  // User deleted Entertainment
  'custom_123456': 'custom_123456',  // User deleted custom category
}
```

## Edge Cases Handled

### 1. Delete Custom Category
- Custom categories also get added to deleted box
- Won't be re-created (custom categories aren't in preset list anyway)
- Provides consistency in deletion handling

### 2. Delete All Preset Categories
- All IDs go to deleted box
- On restart, no preset categories created
- User has completely clean slate

### 3. Fresh Install After Using App
- If user installs on new device
- No deleted_categories box exists
- All presets created as expected

### 4. Selective Deletion
- User deletes "Banking" and "Entertainment"
- Keeps "Gmail", "Work", "Social Media"
- On restart, only deleted ones stay gone
- Kept categories remain

## Testing Checklist

- [x] Delete default category (e.g., Banking)
- [x] Hot restart app
- [x] Verify Banking doesn't reappear
- [x] Delete custom category
- [x] Hot restart app
- [x] Verify custom category doesn't reappear
- [x] Delete multiple categories
- [x] Close and reopen app
- [x] Verify all deleted categories stay deleted
- [x] Uninstall and reinstall app
- [x] Verify all default categories return
- [x] Delete category, create entry, restart
- [x] Verify entry still exists with category reference

## Future Enhancements

### Potential Features
1. **Restore Deleted Categories**: Add UI to restore accidentally deleted categories
2. **Export/Import**: Allow exporting deletion preferences
3. **Reset to Defaults**: Button to clear deleted box and restore all presets
4. **Deletion History**: Track when categories were deleted
5. **Bulk Restore**: Restore multiple deleted categories at once

### Database Schema Enhancement
```dart
class DeletedCategory {
  String id;
  String name;
  DateTime deletedAt;
  String reason; // 'user_deleted', 'admin_deleted', etc.
}
```

## Notes

- Deleted categories box is created automatically on first deletion
- Box persists until app uninstall
- No performance impact (O(1) lookup)
- Memory efficient (only stores strings)
- Works for both preset and custom categories
- No migration needed for existing users (box created on first use)

## Code Locations

**Modified Files**:
- `lib/services/database_service.dart`
  - Added `_deletedCategoriesBoxName` constant
  - Added `_deletedCategoriesBox` field
  - Modified `initialize()` to open deleted box
  - Modified `deleteCategory()` to track deletions
  - Modified `_ensurePresetCategories()` to skip deleted categories

## Conclusion

This fix ensures that user deletion choices are respected and persisted across app sessions. Once a category is deleted, it will not reappear until the app is completely uninstalled and reinstalled, providing a clean and predictable user experience.
