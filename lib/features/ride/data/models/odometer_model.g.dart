// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'odometer_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OdometerModelAdapter extends TypeAdapter<OdometerModel> {
  @override
  final int typeId = 6;

  @override
  OdometerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OdometerModel(
      id: fields[0] as String,
      beforeRideOdometerImage: fields[1] as String?,
      beforeRideOdometerImageCaptureAt: fields[2] as DateTime?,
      afterRideOdometerImage: fields[3] as String?,
      afterRideOdometerImageCaptureAt: fields[4] as DateTime?,
      verificationStatus: fields[5] as OdometerVerificationStatus,
      reasons: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OdometerModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.beforeRideOdometerImage)
      ..writeByte(2)
      ..write(obj.beforeRideOdometerImageCaptureAt)
      ..writeByte(3)
      ..write(obj.afterRideOdometerImage)
      ..writeByte(4)
      ..write(obj.afterRideOdometerImageCaptureAt)
      ..writeByte(5)
      ..write(obj.verificationStatus)
      ..writeByte(6)
      ..write(obj.reasons);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OdometerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
