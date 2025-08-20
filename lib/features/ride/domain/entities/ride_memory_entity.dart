import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RideMemoryEntity extends Equatable {
  // 🔹 Identity
  final String id;

  // 🔹 Content
  final String title;
  final String description;
  final String imageUrl;

  // 🔹 Location
  final GeoPoint capturedCoordinates;

  // 🔹 Timeline
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
