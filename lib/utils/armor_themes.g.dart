// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'armor_themes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArmorThemeModeAdapter extends TypeAdapter<ArmorThemeMode> {
  @override
  final int typeId = 9;

  @override
  ArmorThemeMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ArmorThemeMode.light;
      case 1:
        return ArmorThemeMode.dark;
      case 2:
        return ArmorThemeMode.system;
      case 3:
        return ArmorThemeMode.armor;
      default:
        return ArmorThemeMode.light;
    }
  }

  @override
  void write(BinaryWriter writer, ArmorThemeMode obj) {
    switch (obj) {
      case ArmorThemeMode.light:
        writer.writeByte(0);
        break;
      case ArmorThemeMode.dark:
        writer.writeByte(1);
        break;
      case ArmorThemeMode.system:
        writer.writeByte(2);
        break;
      case ArmorThemeMode.armor:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArmorThemeModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
