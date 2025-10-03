import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ride_memory_entity.dart';

class RideMemoryModel extends RideMemoryEntity {
  const RideMemoryModel({
    super.id,
    super.title,
    super.description,
    super.imageUrl,
    super.capturedCoordinates,
    super.capturedAt,
  });

  factory RideMemoryModel.fromFirestore(Map<String, dynamic> json) {
    GeoPoint? coordinates;
    if (json['capturedCoordinates'] is GeoPoint) {
      coordinates = json['capturedCoordinates'] as GeoPoint?;
    } else if (json['capturedCoordinates'] is Map<String, dynamic>) {
      final coords = json['capturedCoordinates'] as Map<String, dynamic>;
      coordinates = GeoPoint(
        (coords['latitude'] as num).toDouble(),
        (coords['longitude'] as num).toDouble(),
      );
    }

    DateTime? capturedAt;
    if (json['capturedAt'] is Timestamp) {
      capturedAt = (json['capturedAt'] as Timestamp).toDate();
    } else if (json['capturedAt'] is String) {
      capturedAt = DateTime.tryParse(json['capturedAt']);
    }

    return RideMemoryModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      capturedCoordinates: coordinates,
      capturedAt: capturedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (capturedCoordinates != null)
        'capturedCoordinates': capturedCoordinates,
      if (capturedAt != null) 'capturedAt': Timestamp.fromDate(capturedAt!),
    };
  }

  /// 🔹 Hive / JSON support
  factory RideMemoryModel.fromJson(Map<String, dynamic> json) {
    GeoPoint? coordinates;
    if (json['capturedCoordinates'] != null) {
      final coords = json['capturedCoordinates'] as Map<String, dynamic>;
      coordinates = GeoPoint(
        (coords['latitude'] as num).toDouble(),
        (coords['longitude'] as num).toDouble(),
      );
    }

    return RideMemoryModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      capturedCoordinates: coordinates,
      capturedAt: json['capturedAt'] != null
          ? DateTime.parse(json['capturedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'capturedCoordinates': capturedCoordinates != null
          ? {
              'latitude': capturedCoordinates!.latitude,
              'longitude': capturedCoordinates!.longitude,
            }
          : null,
      'capturedAt': capturedAt?.toIso8601String(),
    };
  }

  RideMemoryModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    GeoPoint? capturedCoordinates,
    DateTime? capturedAt,
  }) {
    return RideMemoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      capturedCoordinates: capturedCoordinates ?? this.capturedCoordinates,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }

  static RideMemoryModel fromEntity(RideMemoryEntity? entity) {
    if (entity == null) return const RideMemoryModel();
    return RideMemoryModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      imageUrl: entity.imageUrl,
      capturedCoordinates: entity.capturedCoordinates,
      capturedAt: entity.capturedAt,
    );
  }
}
