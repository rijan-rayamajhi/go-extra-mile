// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RideEntityAdapter extends TypeAdapter<RideEntity> {
  @override
  final int typeId = 2;

  @override
  RideEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RideEntity(
      id: fields[0] as String,
      userId: fields[1] as String,
      vehicleId: fields[2] as String,
      status: fields[3] as String,
      startedAt: fields[4] as DateTime,
      startCoordinates: fields[5] as GeoPoint,
      endCoordinates: fields[6] as GeoPoint?,
      endedAt: fields[7] as DateTime?,
      totalDistance: fields[8] as double?,
      totalTime: fields[9] as double?,
      totalGEMCoins: fields[10] as double?,
      rideMemories: (fields[11] as List?)?.cast<RideMemoryEntity>(),
      rideTitle: fields[12] as String?,
      rideDescription: fields[13] as String?,
      topSpeed: fields[14] as double?,
      averageSpeed: fields[15] as double?,
      routePoints: (fields[16] as List?)?.cast<GeoPoint>(),
      isPublic: fields[17] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, RideEntity obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.vehicleId)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.startedAt)
      ..writeByte(5)
      ..write(obj.startCoordinates)
      ..writeByte(6)
      ..write(obj.endCoordinates)
      ..writeByte(7)
      ..write(obj.endedAt)
      ..writeByte(8)
      ..write(obj.totalDistance)
      ..writeByte(9)
      ..write(obj.totalTime)
      ..writeByte(10)
      ..write(obj.totalGEMCoins)
      ..writeByte(11)
      ..write(obj.rideMemories)
      ..writeByte(12)
      ..write(obj.rideTitle)
      ..writeByte(13)
      ..write(obj.rideDescription)
      ..writeByte(14)
      ..write(obj.topSpeed)
      ..writeByte(15)
      ..write(obj.averageSpeed)
      ..writeByte(16)
      ..write(obj.routePoints)
      ..writeByte(17)
      ..write(obj.isPublic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RideEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
