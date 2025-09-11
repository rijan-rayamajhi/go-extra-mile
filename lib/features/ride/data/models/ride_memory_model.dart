import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/ride_memory_entity.dart';

part 'ride_memory_model.g.dart';

@HiveType(typeId: 5)
class RideMemoryModel extends RideMemoryEntity {
  const RideMemoryModel({
    @HiveField(0) required super.id,
    @HiveField(1) required super.title,
    @HiveField(2) required super.description,
    @HiveField(3) required super.imageUrl,
    @HiveField(4) required super.capturedCoordinates,
    @HiveField(5) required super.capturedAt,
  });

  /// ✅ Firestore -> Model
  factory RideMemoryModel.fromFirestore(Map<String, dynamic> json) {
    // Handle different coordinate formats from Firestore
    GeoPoint capturedCoordinates;
    if (json['capturedCoordinates'] is GeoPoint) {
      capturedCoordinates = json['capturedCoordinates'] as GeoPoint;
    } else if (json['capturedCoordinates'] is Map<String, dynamic>) {
      final coordsMap = json['capturedCoordinates'] as Map<String, dynamic>;
      capturedCoordinates = GeoPoint(
        (coordsMap['latitude'] as num).toDouble(),
        (coordsMap['longitude'] as num).toDouble(),
      );
    } else {
      throw FormatException('Invalid capturedCoordinates format: ${json['capturedCoordinates']}');
    }

    // Handle different timestamp formats from Firestore
    DateTime capturedAt;
    if (json['capturedAt'] is Timestamp) {
      capturedAt = (json['capturedAt'] as Timestamp).toDate();
    } else if (json['capturedAt'] is String) {
      capturedAt = DateTime.parse(json['capturedAt'] as String);
    } else if (json['capturedAt'] is int) {
      // Handle milliseconds since epoch
      capturedAt = DateTime.fromMillisecondsSinceEpoch(json['capturedAt'] as int);
    } else {
      throw FormatException('Invalid capturedAt format: ${json['capturedAt']}');
    }

    return RideMemoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      capturedCoordinates: capturedCoordinates,
      capturedAt: capturedAt,
    );
  }

  /// ✅ JSON -> Model (for local storage)
  factory RideMemoryModel.fromJson(Map<String, dynamic> json) {
    return RideMemoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      capturedCoordinates: GeoPoint(
        (json['capturedCoordinates']['latitude'] as num).toDouble(),
        (json['capturedCoordinates']['longitude'] as num).toDouble(),
      ),
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }

  /// ✅ Model -> Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'capturedCoordinates': capturedCoordinates,
      'capturedAt': Timestamp.fromDate(capturedAt),
    };
  }

  /// ✅ Model -> JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'capturedCoordinates': {
        'latitude': capturedCoordinates.latitude,
        'longitude': capturedCoordinates.longitude,
      },
      'capturedAt': capturedAt.toIso8601String(),
    };
  }

  /// ✅ CopyWith
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

  /// ✅ Mappers
  RideMemoryEntity toEntity() => this;

  static RideMemoryModel fromEntity(RideMemoryEntity entity) => RideMemoryModel(
        id: entity.id,
        title: entity.title,
        description: entity.description,
        imageUrl: entity.imageUrl,
        capturedCoordinates: entity.capturedCoordinates,
        capturedAt: entity.capturedAt,
      );

  /// 🔹 From Hive
  factory RideMemoryModel.fromHive(Map<String, dynamic> hiveData) {
    return RideMemoryModel(
      id: hiveData['id'] as String,
      title: hiveData['title'] as String,
      description: hiveData['description'] as String,
      imageUrl: hiveData['imageUrl'] as String,
      capturedCoordinates: GeoPoint(
        hiveData['capturedLat'] as double,
        hiveData['capturedLng'] as double,
      ),
      capturedAt: DateTime.fromMillisecondsSinceEpoch(hiveData['capturedAt'] as int),
    );
  }

  /// 🔹 To Hive
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'capturedLat': capturedCoordinates.latitude,
      'capturedLng': capturedCoordinates.longitude,
      'capturedAt': capturedAt.millisecondsSinceEpoch,
    };
  }
}
