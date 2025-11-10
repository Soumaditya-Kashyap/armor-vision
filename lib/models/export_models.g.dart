// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExportFormatAdapter extends TypeAdapter<ExportFormat> {
  @override
  final int typeId = 10;

  @override
  ExportFormat read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExportFormat.pdf;
      default:
        return ExportFormat.pdf;
    }
  }

  @override
  void write(BinaryWriter writer, ExportFormat obj) {
    switch (obj) {
      case ExportFormat.pdf:
        writer.writeByte(0);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportFormatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
