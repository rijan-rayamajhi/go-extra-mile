import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'ride_memory_entity.g.dart';

@HiveType(typeId: 3)
class RideMemoryEntity extends Equatable {
  // 🔹 Identity
  @HiveField(0)
  final String id;

  // 🔹 Content
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String imageUrl;

  // 🔹 Location
  @HiveField(4)
  final GeoPoint capturedCoordinates;

  // 🔹 Timeline
  @HiveField(5)
  final DateTime capturedAt;

  const RideMemoryEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.capturedCoordinates,
    required this.capturedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        capturedCoordinates,
        capturedAt,
      ];
}
