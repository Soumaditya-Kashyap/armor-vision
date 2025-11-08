// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 5;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkMode: fields[0] as bool,
      isBiometricEnabled: fields[1] as bool,
      autoLockTimeoutMinutes: fields[2] as int,
      isFirstLaunch: fields[3] as bool,
      defaultCategory: fields[4] as String,
      defaultSortOption: fields[5] as SortOption,
      defaultViewMode: fields[6] as ViewMode,
      showPasswordStrength: fields[7] as bool,
      enableAutoBackup: fields[8] as bool,
      maxBackupFiles: fields[9] as int,
      showRecentlyUsed: fields[10] as bool,
      enableSearchHistory: fields[11] as bool,
      showTips: fields[12] as bool,
      language: fields[13] as String,
      enableHapticFeedback: fields[14] as bool,
      securityLevel: fields[15] as SecurityLevel,
      lastBackupAt: fields[16] as DateTime?,
      totalEntries: fields[17] as int,
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime,
      themeMode: fields[20] as ArmorThemeMode?,
      armorFolderMigrated: fields[21] == null ? false : fields[21] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.isBiometricEnabled)
      ..writeByte(2)
      ..write(obj.autoLockTimeoutMinutes)
      ..writeByte(3)
      ..write(obj.isFirstLaunch)
      ..writeByte(4)
      ..write(obj.defaultCategory)
      ..writeByte(5)
      ..write(obj.defaultSortOption)
      ..writeByte(6)
      ..write(obj.defaultViewMode)
      ..writeByte(7)
      ..write(obj.showPasswordStrength)
      ..writeByte(8)
      ..write(obj.enableAutoBackup)
      ..writeByte(9)
      ..write(obj.maxBackupFiles)
      ..writeByte(10)
      ..write(obj.showRecentlyUsed)
      ..writeByte(11)
      ..write(obj.enableSearchHistory)
      ..writeByte(12)
      ..write(obj.showTips)
      ..writeByte(13)
      ..write(obj.language)
      ..writeByte(14)
      ..write(obj.enableHapticFeedback)
      ..writeByte(15)
      ..write(obj.securityLevel)
      ..writeByte(16)
      ..write(obj.lastBackupAt)
      ..writeByte(17)
      ..write(obj.totalEntries)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.themeMode)
      ..writeByte(21)
      ..write(obj.armorFolderMigrated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SortOptionAdapter extends TypeAdapter<SortOption> {
  @override
  final int typeId = 6;

  @override
  SortOption read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SortOption.alphabetical;
      case 1:
        return SortOption.dateCreated;
      case 2:
        return SortOption.dateModified;
      case 3:
        return SortOption.lastAccessed;
      case 4:
        return SortOption.category;
      case 5:
        return SortOption.favorite;
      default:
        return SortOption.alphabetical;
    }
  }

  @override
  void write(BinaryWriter writer, SortOption obj) {
    switch (obj) {
      case SortOption.alphabetical:
        writer.writeByte(0);
        break;
      case SortOption.dateCreated:
        writer.writeByte(1);
        break;
      case SortOption.dateModified:
        writer.writeByte(2);
        break;
      case SortOption.lastAccessed:
        writer.writeByte(3);
        break;
      case SortOption.category:
        writer.writeByte(4);
        break;
      case SortOption.favorite:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortOptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ViewModeAdapter extends TypeAdapter<ViewMode> {
  @override
  final int typeId = 7;

  @override
  ViewMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ViewMode.grid;
      case 1:
        return ViewMode.list;
      case 2:
        return ViewMode.compact;
      default:
        return ViewMode.grid;
    }
  }

  @override
  void write(BinaryWriter writer, ViewMode obj) {
    switch (obj) {
      case ViewMode.grid:
        writer.writeByte(0);
        break;
      case ViewMode.list:
        writer.writeByte(1);
        break;
      case ViewMode.compact:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SecurityLevelAdapter extends TypeAdapter<SecurityLevel> {
  @override
  final int typeId = 8;

  @override
  SecurityLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SecurityLevel.standard;
      case 1:
        return SecurityLevel.high;
      case 2:
        return SecurityLevel.maximum;
      default:
        return SecurityLevel.standard;
    }
  }

  @override
  void write(BinaryWriter writer, SecurityLevel obj) {
    switch (obj) {
      case SecurityLevel.standard:
        writer.writeByte(0);
        break;
      case SecurityLevel.high:
        writer.writeByte(1);
        break;
      case SecurityLevel.maximum:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
