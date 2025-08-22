import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/ride_memory_entity.dart';
import 'ride_memory_model.dart';

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.userId,
    required super.vehicleId,
    required super.status,
    required super.startedAt,
    required super.startCoordinates,
    super.endCoordinates,
    super.endedAt,
    super.totalDistance,
    super.totalTime,
    super.totalGEMCoins,
    super.rideMemories,
    super.rideTitle,
    super.rideDescription,
    super.topSpeed,
    super.averageSpeed,
    super.routePoints,
  });

  /// 🔹 copyWith
  RideModel copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    String? status,
    DateTime? startedAt,
    GeoPoint? startCoordinates,
    GeoPoint? endCoordinates,
    DateTime? endedAt,
    double? totalDistance,
    double? totalTime,
    double? totalGEMCoins,
    List<RideMemoryEntity>? rideMemories,
    String? rideTitle,
    String? rideDescription,
    double? topSpeed,
    double? averageSpeed,
    List<GeoPoint>? routePoints,
  }) {
    return RideModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleId: vehicleId ?? this.vehicleId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      startCoordinates: startCoordinates ?? this.startCoordinates,
      endCoordinates: endCoordinates ?? this.endCoordinates,
      endedAt: endedAt ?? this.endedAt,
      totalDistance: totalDistance ?? this.totalDistance,
      totalTime: totalTime ?? this.totalTime,
      totalGEMCoins: totalGEMCoins ?? this.totalGEMCoins,
      rideMemories: rideMemories ?? this.rideMemories,
      rideTitle: rideTitle ?? this.rideTitle,
      rideDescription: rideDescription ?? this.rideDescription,
      topSpeed: topSpeed ?? this.topSpeed,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  /// 🔹 From Firestore
  factory RideModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RideModel(
      id: doc.id,
      userId: data['userId'] as String,
      vehicleId: data['vehicleId'] as String,
      status: data['status'] as String,
      startedAt: (data['startedAt'] as Timestamp).toDate(),
      startCoordinates: data['startCoordinates'] as GeoPoint,
      endCoordinates: data['endCoordinates'] as GeoPoint?,
      endedAt: data['endedAt'] != null ? (data['endedAt'] as Timestamp).toDate() : null,
      totalDistance: data['totalDistance'] as double?,
      totalTime: data['totalTime'] as double?,
      totalGEMCoins: data['totalGEMCoins'] as double?,
      rideMemories: data['rideMemories'] != null 
          ? (data['rideMemories'] as List<dynamic>)
              .map((memory) => RideMemoryModel.fromFirestore(memory as Map<String, dynamic>))
              .toList()
          : null,
      rideTitle: data['rideTitle'] as String?,
      rideDescription: data['rideDescription'] as String?,
      topSpeed: data['topSpeed'] as double?,
      averageSpeed: data['averageSpeed'] as double?,
      routePoints: data['routePoints'] != null 
          ? (data['routePoints'] as List<dynamic>)
              .map((point) => point as GeoPoint)
              .toList()
          : null,
    );
  }

  /// 🔹 To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'status': status,
      'startedAt': Timestamp.fromDate(startedAt),
      'startCoordinates': startCoordinates,
      'endCoordinates': endCoordinates,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'totalDistance': totalDistance,
      'totalTime': totalTime,
      'totalGEMCoins': totalGEMCoins,
      'rideMemories': rideMemories?.map((memory) {
        if (memory is RideMemoryModel) {
          return memory.toJson();
        }
        return RideMemoryModel.fromEntity(memory).toJson();
      }).toList(),
      'rideTitle': rideTitle,
      'rideDescription': rideDescription,
      'topSpeed': topSpeed,
      'averageSpeed': averageSpeed,
      'routePoints': routePoints,
    };
  }

  /// 🔹 From JSON
  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      vehicleId: json['vehicleId'] as String,
      status: json['status'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      startCoordinates: GeoPoint(
        (json['startLat'] as num).toDouble(),
        (json['startLng'] as num).toDouble(),
      ),
      endCoordinates: json['endLat'] != null && json['endLng'] != null
          ? GeoPoint(
              (json['endLat'] as num).toDouble(),
              (json['endLng'] as num).toDouble(),
            )
          : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt'] as String) : null,
      totalDistance: json['totalDistance'] as double?,
      totalTime: json['totalTime'] as double?,
      totalGEMCoins: json['totalGEMCoins'] as double?,
      rideMemories: json['rideMemories'] != null
          ? (json['rideMemories'] as List<dynamic>)
              .map((memory) => RideMemoryModel.fromJson(memory as Map<String, dynamic>))
              .toList()
          : null,
      rideTitle: json['rideTitle'] as String?,
      rideDescription: json['rideDescription'] as String?,
      topSpeed: json['topSpeed'] as double?,
      averageSpeed: json['averageSpeed'] as double?,
      routePoints: json['routePoints'] != null
          ? (json['routePoints'] as List<dynamic>)
              .map((point) => GeoPoint(
                (point['latitude'] as num).toDouble(),
                (point['longitude'] as num).toDouble(),
              ))
              .toList()
          : null,
    );
  }

  /// 🔹 To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'status': status,
      'startedAt': startedAt.toIso8601String(),
      'startLat': startCoordinates.latitude,
      'startLng': startCoordinates.longitude,
      'endLat': endCoordinates?.latitude,
      'endLng': endCoordinates?.longitude,
      'endedAt': endedAt?.toIso8601String(),
      'totalDistance': totalDistance,
      'totalTime': totalTime,
      'totalGEMCoins': totalGEMCoins,
      'rideMemories': rideMemories?.map((memory) {
        if (memory is RideMemoryModel) {
          return memory.toJson();
        }
        return RideMemoryModel.fromEntity(memory).toJson();
      }).toList(),
      'rideTitle': rideTitle,
      'rideDescription': rideDescription,
      'topSpeed': topSpeed,
      'averageSpeed': averageSpeed,
      'routePoints': routePoints?.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
    };
  }
}
