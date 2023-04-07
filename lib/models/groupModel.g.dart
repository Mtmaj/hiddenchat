// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groupModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupAdapter extends TypeAdapter<Group> {
  @override
  final int typeId = 1;

  @override
  Group read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Group(
      group_name: fields[0] as String?,
      group_id: fields[1] as int?,
      group_password: fields[2] as String?,
      group_users: (fields[3] as List?)?.cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, Group obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.group_name)
      ..writeByte(1)
      ..write(obj.group_id)
      ..writeByte(2)
      ..write(obj.group_password)
      ..writeByte(3)
      ..write(obj.group_users);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
