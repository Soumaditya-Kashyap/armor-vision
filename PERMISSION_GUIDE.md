# Storage Permission Setup Guide

## What Changed

The app now requests **MANAGE_EXTERNAL_STORAGE** permission on Android 11+ to create the `/storage/emulated/0/Armor/` folder in your device's internal storage root.

## What You'll See

### 1. **First Launch - Permission Dialog**
When the app launches, you'll see a system dialog asking for **"All files access"** or **"Manage all files"** permission.

### 2. **What to Do**
- Tap **"Allow"** or **"Grant"**
- This takes you to Settings → Special app access → All files access
- Find **"Armor"** in the list
- Toggle the switch to **ON** (enable)
- Press **Back** to return to the app

### 3. **After Granting Permission**
The app will:
- ✅ Create `/storage/emulated/0/Armor/` folder
- ✅ Export your 2 entries to `entries.json`
- ✅ Export your categories to `categories.json`
- ✅ Create `info.txt` with hash verification guide

## Viewing Your Data

### Using Files App (Built-in)
1. Open **Files** or **My Files** app on your phone
2. Navigate to **Internal Storage** → **Armor**
3. You'll see:
   - `entries.json` (your passwords with SHA-256 hashes)
   - `categories.json` (your categories)
   - `info.txt` (how to verify hashes)

### What You'll Find in entries.json
```json
{
  "exportDate": "2025-11-08T...",
  "encryptionMethod": "AES-256-GCM",
  "totalEntries": 2,
  "entries": [
    {
      "id": "entry_1",
      "title": "Gmail",
      "fields": [
        {
          "label": "Password",
          "passwordHash": "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8",
          "encryptedValue": "ENC:U2FsdGVkX1+...",
          "type": "password"
        }
      ]
    }
  ]
}
```

## Verifying Password Hashes

### Online Method (Easiest)
1. Go to https://emn178.github.io/online-tools/sha256.html
2. Enter your actual password (e.g., "password123")
3. Click "Hash"
4. Compare the result with `passwordHash` in `entries.json`
5. They should match exactly!

### Manual Method (Technical)
```bash
# Linux/Mac terminal
echo -n "YourPassword123" | sha256sum

# Windows PowerShell
echo -n "YourPassword123" | openssl dgst -sha256
```

## Settings Screen

Go to **Settings** → **Data Transparency** to see:
- ✅ Status: Active
- 📅 Last Synced: 2 minutes ago
- 📊 Entries Exported: 2 entries
- 📂 Location: /storage/emulated/0/Armor/
- 🔄 Resync Now button
- 📋 Copy Path button

## Troubleshooting

### ❌ "Status: Not Created"
**Cause**: Permission was denied
**Fix**: 
1. Go to Android Settings
2. Apps → Armor → Permissions
3. Files and media → Allow access to manage all files
4. Return to app → Settings → Data Transparency → Tap "Resync Now"

### ❌ Permission Dialog Doesn't Appear
**Fix**: 
1. Uninstall the app completely
2. Reinstall from Flutter
3. Grant permission when prompted

### ❌ "Permission denied" error in console
**Cause**: Running on old app version without new manifest
**Fix**: 
1. Run `flutter clean`
2. Uninstall app from device
3. Run `flutter run` again

## Technical Details

### Android Manifest Changes
```xml
<!-- Android 11+ permission -->
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />

<!-- Legacy storage for Android 10 -->
<application android:requestLegacyExternalStorage="true">
```

### Permission Logic
- **Android 11+ (API 30+)**: Requires MANAGE_EXTERNAL_STORAGE → Takes user to Settings
- **Android 10 (API 29)**: Uses regular WRITE_EXTERNAL_STORAGE
- **Android 9- (API 28-)**: Uses regular WRITE_EXTERNAL_STORAGE

### Console Output (Success)
```
📱 Android version: 30
📱 Android 11+ detected - checking MANAGE_EXTERNAL_STORAGE
🔔 Requesting MANAGE_EXTERNAL_STORAGE permission...
✅ MANAGE_EXTERNAL_STORAGE granted by user
🔄 Initializing Armor folder...
✅ Created Armor folder: /storage/emulated/0/Armor
📤 Exporting 2 existing entries...
✅ Armor folder migration complete!
📂 Your data is now available at /storage/emulated/0/Armor/
```

## Why This Permission?

### User Benefits
- 🔍 **Transparency**: See your encrypted data as files
- 🛡️ **Trust**: Verify password hashes match
- 💾 **Backup**: Copy folder to computer via USB
- 📱 **Accessible**: Use any file manager app
- 🔓 **No Cloud**: Everything stays on your device

### What We DON'T Do
- ❌ Never access other apps' data
- ❌ Never upload to internet
- ❌ Never scan your storage
- ❌ Only read/write /storage/emulated/0/Armor/ folder

## Privacy Guarantee

The Armor folder only contains:
1. **Your password entries** (encrypted + hashed)
2. **Your categories** (names, icons, colors)
3. **Info file** (usage instructions)

**Nothing else is accessed or stored!**

---

Need help? Check console logs for detailed error messages.
