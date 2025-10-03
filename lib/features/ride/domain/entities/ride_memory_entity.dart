import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RideMemoryEntity extends Equatable {
  // 🔹 Identity
  final String? id;

  // 🔹 Content
  final String? title;
  final String? description;
  final String? imageUrl;

  // 🔹 Location
  final GeoPoint? capturedCoordinates;

  // 🔹 Timeline
  final DateTime? capturedAt;

  const RideMemoryEntity({
    this.id,
    this.title,
    this.description,
    this.imageUrl,
    this.capturedCoordinates,
    this.capturedAt,
  });

  /// 🔹 CopyWith
  RideMemoryEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    GeoPoint? capturedCoordinates,
    DateTime? capturedAt,
  }) {
    return RideMemoryEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      capturedCoordinates: capturedCoordinates ?? this.capturedCoordinates,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

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
