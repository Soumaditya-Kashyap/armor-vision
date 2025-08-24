// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PasswordEntryAdapter extends TypeAdapter<PasswordEntry> {
  @override
  final int typeId = 0;

  @override
  PasswordEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PasswordEntry(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      customFields: (fields[3] as List).cast<CustomField>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      category: fields[6] as String?,
      isFavorite: fields[7] as bool,
      imagePath: fields[8] as String?,
      tags: (fields[9] as List).cast<String>(),
      color: fields[10] as EntryColor,
      accessCount: fields[11] as int,
      lastAccessedAt: fields[12] as DateTime?,
      isArchived: fields[13] as bool,
      notes: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PasswordEntry obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.customFields)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.color)
      ..writeByte(11)
      ..write(obj.accessCount)
      ..writeByte(12)
      ..write(obj.lastAccessedAt)
      ..writeByte(13)
      ..write(obj.isArchived)
      ..writeByte(14)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PasswordEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomFieldAdapter extends TypeAdapter<CustomField> {
  @override
  final int typeId = 1;

  @override
  CustomField read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomField(
      label: fields[0] as String,
      value: fields[1] as String,
      type: fields[2] as FieldType,
      isRequired: fields[3] as bool,
      isHidden: fields[4] as bool,
      sortOrder: fields[5] as int,
      isCopyable: fields[6] as bool,
      hint: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomField obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.label)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.isRequired)
      ..writeByte(4)
      ..write(obj.isHidden)
      ..writeByte(5)
      ..write(obj.sortOrder)
      ..writeByte(6)
      ..write(obj.isCopyable)
      ..writeByte(7)
      ..write(obj.hint);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomFieldAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 4;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      color: fields[3] as EntryColor,
      iconName: fields[4] as String,
      createdAt: fields[5] as DateTime,
      sortOrder: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.color)
      ..writeByte(4)
      ..write(obj.iconName)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FieldTypeAdapter extends TypeAdapter<FieldType> {
  @override
  final int typeId = 2;

  @override
  FieldType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FieldType.text;
      case 1:
        return FieldType.password;
      case 2:
        return FieldType.email;
      case 3:
        return FieldType.url;
      case 4:
        return FieldType.number;
      case 5:
        return FieldType.note;
      case 6:
        return FieldType.phone;
      case 7:
        return FieldType.date;
      case 8:
        return FieldType.bankAccount;
      case 9:
        return FieldType.creditCard;
      case 10:
        return FieldType.socialSecurity;
      case 11:
        return FieldType.username;
      case 12:
        return FieldType.pin;
      default:
        return FieldType.text;
    }
  }

  @override
  void write(BinaryWriter writer, FieldType obj) {
    switch (obj) {
      case FieldType.text:
        writer.writeByte(0);
        break;
      case FieldType.password:
        writer.writeByte(1);
        break;
      case FieldType.email:
        writer.writeByte(2);
        break;
      case FieldType.url:
        writer.writeByte(3);
        break;
      case FieldType.number:
        writer.writeByte(4);
        break;
      case FieldType.note:
        writer.writeByte(5);
        break;
      case FieldType.phone:
        writer.writeByte(6);
        break;
      case FieldType.date:
        writer.writeByte(7);
        break;
      case FieldType.bankAccount:
        writer.writeByte(8);
        break;
      case FieldType.creditCard:
        writer.writeByte(9);
        break;
      case FieldType.socialSecurity:
        writer.writeByte(10);
        break;
      case FieldType.username:
        writer.writeByte(11);
        break;
      case FieldType.pin:
        writer.writeByte(12);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class EntryColorAdapter extends TypeAdapter<EntryColor> {
  @override
  final int typeId = 3;

  @override
  EntryColor read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EntryColor.blue;
      case 1:
        return EntryColor.green;
      case 2:
        return EntryColor.orange;
      case 3:
        return EntryColor.red;
      case 4:
        return EntryColor.purple;
      case 5:
        return EntryColor.teal;
      case 6:
        return EntryColor.pink;
      case 7:
        return EntryColor.indigo;
      case 8:
        return EntryColor.amber;
      case 9:
        return EntryColor.gray;
      default:
        return EntryColor.blue;
    }
  }

  @override
  void write(BinaryWriter writer, EntryColor obj) {
    switch (obj) {
      case EntryColor.blue:
        writer.writeByte(0);
        break;
      case EntryColor.green:
        writer.writeByte(1);
        break;
      case EntryColor.orange:
        writer.writeByte(2);
        break;
      case EntryColor.red:
        writer.writeByte(3);
        break;
      case EntryColor.purple:
        writer.writeByte(4);
        break;
      case EntryColor.teal:
        writer.writeByte(5);
        break;
      case EntryColor.pink:
        writer.writeByte(6);
        break;
      case EntryColor.indigo:
        writer.writeByte(7);
        break;
      case EntryColor.amber:
        writer.writeByte(8);
        break;
      case EntryColor.gray:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryColorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
