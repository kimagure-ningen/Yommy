// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderSettingsAdapter extends TypeAdapter<ReminderSettings> {
  @override
  final int typeId = 2;

  @override
  ReminderSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderSettings(
      enabled: fields[0] as bool,
      hour: fields[1] as int,
      minute: fields[2] as int,
      mode: fields[3] as ReminderMode,
      articleCount: fields[4] as int,
      activeDays: (fields[5] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReminderSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.enabled)
      ..writeByte(1)
      ..write(obj.hour)
      ..writeByte(2)
      ..write(obj.minute)
      ..writeByte(3)
      ..write(obj.mode)
      ..writeByte(4)
      ..write(obj.articleCount)
      ..writeByte(5)
      ..write(obj.activeDays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReminderModeAdapter extends TypeAdapter<ReminderMode> {
  @override
  final int typeId = 3;

  @override
  ReminderMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReminderMode.random;
      case 1:
        return ReminderMode.oldest;
      case 2:
        return ReminderMode.newest;
      default:
        return ReminderMode.random;
    }
  }

  @override
  void write(BinaryWriter writer, ReminderMode obj) {
    switch (obj) {
      case ReminderMode.random:
        writer.writeByte(0);
        break;
      case ReminderMode.oldest:
        writer.writeByte(1);
        break;
      case ReminderMode.newest:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
