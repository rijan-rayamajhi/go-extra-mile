import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class GeoPointAdapter extends TypeAdapter<GeoPoint> {
  @override
  final int typeId = 0;

  @override
  GeoPoint read(BinaryReader reader) {
    final lat = reader.readDouble();
    final lng = reader.readDouble();
    return GeoPoint(lat, lng);
  }

  @override
  void write(BinaryWriter writer, GeoPoint obj) {
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
}
