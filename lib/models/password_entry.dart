import 'package:hive/hive.dart';

part 'password_entry.g.dart';

@HiveType(typeId: 0)
class PasswordEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<CustomField> customFields;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  String? category;

  @HiveField(7)
  bool isFavorite;

  @HiveField(8)
  String? imagePath;

  @HiveField(9)
  List<String> tags;

  @HiveField(10)
  EntryColor color;

  @HiveField(11)
  int accessCount;

  @HiveField(12)
  DateTime? lastAccessedAt;

  @HiveField(13)
  bool isArchived;

  @HiveField(14)
  String? notes;

  PasswordEntry({
    required this.id,
    required this.title,
    this.description,
    required this.customFields,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.isFavorite = false,
    this.imagePath,
    this.tags = const [],
    this.color = EntryColor.blue,
    this.accessCount = 0,
    this.lastAccessedAt,
    this.isArchived = false,
    this.notes,
  });

  PasswordEntry copyWith({
    String? id,
    String? title,
    String? description,
    List<CustomField>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    bool? isFavorite,
    String? imagePath,
    List<String>? tags,
    EntryColor? color,
    int? accessCount,
    DateTime? lastAccessedAt,
    bool? isArchived,
    String? notes,
  }) {
    return PasswordEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      imagePath: imagePath ?? this.imagePath,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      accessCount: accessCount ?? this.accessCount,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isArchived: isArchived ?? this.isArchived,
      notes: notes ?? this.notes,
    );
  }

  // Helper methods
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get isRecentlyAccessed =>
      lastAccessedAt != null &&
      DateTime.now().difference(lastAccessedAt!).inDays < 7;

  String get displayTitle => title.isEmpty ? 'Untitled Entry' : title;

  CustomField? getFieldByType(FieldType type) {
    try {
      return customFields.firstWhere((field) => field.type == type);
    } catch (e) {
      return null;
    }
  }

  List<CustomField> get passwordFields =>
      customFields.where((field) => field.type == FieldType.password).toList();

  List<CustomField> get visibleFields =>
      customFields.where((field) => !field.isHidden).toList();
}

@HiveType(typeId: 1)
class CustomField extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  String value;

  @HiveField(2)
  FieldType type;

  @HiveField(3)
  bool isRequired;

  @HiveField(4)
  bool isHidden;

  @HiveField(5)
  int sortOrder;

  @HiveField(6)
  bool isCopyable;

  @HiveField(7)
  String? hint;

  CustomField({
    required this.label,
    required this.value,
    required this.type,
    this.isRequired = false,
    this.isHidden = false,
    this.sortOrder = 0,
    this.isCopyable = true,
    this.hint,
  });

  CustomField copyWith({
    String? label,
    String? value,
    FieldType? type,
    bool? isRequired,
    bool? isHidden,
    int? sortOrder,
    bool? isCopyable,
    String? hint,
  }) {
    return CustomField(
      label: label ?? this.label,
      value: value ?? this.value,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      isHidden: isHidden ?? this.isHidden,
      sortOrder: sortOrder ?? this.sortOrder,
      isCopyable: isCopyable ?? this.isCopyable,
      hint: hint ?? this.hint,
    );
  }

  bool get isEmpty => value.trim().isEmpty;
  bool get isNotEmpty => !isEmpty;
}

@HiveType(typeId: 2)
enum FieldType {
  @HiveField(0)
  text,

  @HiveField(1)
  password,

  @HiveField(2)
  email,

  @HiveField(3)
  url,

  @HiveField(4)
  number,

  @HiveField(5)
  note,

  @HiveField(6)
  phone,

  @HiveField(7)
  date,

  @HiveField(8)
  bankAccount,

  @HiveField(9)
  creditCard,

  @HiveField(10)
  socialSecurity,

  @HiveField(11)
  username,

  @HiveField(12)
  pin,
}

@HiveType(typeId: 3)
enum EntryColor {
  @HiveField(0)
  blue,

  @HiveField(1)
  green,

  @HiveField(2)
  orange,

  @HiveField(3)
  red,

  @HiveField(4)
  purple,

  @HiveField(5)
  teal,

  @HiveField(6)
  pink,

  @HiveField(7)
  indigo,

  @HiveField(8)
  amber,

  @HiveField(9)
  gray,
}

@HiveType(typeId: 4)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  EntryColor color;

  @HiveField(4)
  String iconName;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  int sortOrder;

  Category({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.iconName,
    required this.createdAt,
    this.sortOrder = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    String? description,
    EntryColor? color,
    String? iconName,
    DateTime? createdAt,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
