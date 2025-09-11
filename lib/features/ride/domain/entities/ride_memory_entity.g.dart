// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_memory_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RideMemoryEntityAdapter extends TypeAdapter<RideMemoryEntity> {
  @override
  final int typeId = 3;

  @override
  RideMemoryEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RideMemoryEntity(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String,
      capturedCoordinates: fields[4] as GeoPoint,
      capturedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RideMemoryEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.capturedCoordinates)
      ..writeByte(5)
      ..write(obj.capturedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideMemoryEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
