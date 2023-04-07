// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messageModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 0;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Message(
      from: fields[0] as String?,
      to: fields[1] as int?,
      text: fields[2] as String?,
      replay: fields[3] as String?,
      time: fields[4] as String?,
      id: fields[5] as String?,
      isSend: fields[6] as bool,
      isSeen: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.from)
      ..writeByte(1)
      ..write(obj.to)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.replay)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.id)
      ..writeByte(6)
      ..write(obj.isSend)
      ..writeByte(7)
      ..write(obj.isSeen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
