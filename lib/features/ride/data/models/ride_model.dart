import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/ride_memory_entity.dart';
import '../../domain/entities/odometer_entity.dart';
import 'ride_memory_model.dart';
import 'odometer_model.dart';

part 'ride_model.g.dart';

@HiveType(typeId: 4)
class RideModel extends RideEntity {
  const RideModel({
    @HiveField(0) required super.id,
    @HiveField(1) required super.userId,
    @HiveField(2) required super.vehicleId,
    @HiveField(3) required super.status,
    @HiveField(4) required super.startedAt,
    @HiveField(5) required super.startCoordinates,
    @HiveField(6) super.endCoordinates,
    @HiveField(7) super.endedAt,
    @HiveField(8) super.totalDistance,
    @HiveField(9) super.totalTime,
    @HiveField(10) super.totalGEMCoins,
    @HiveField(11) super.rideMemories,
    @HiveField(12) super.rideTitle,
    @HiveField(13) super.rideDescription,
    @HiveField(14) super.topSpeed,
    @HiveField(15) super.averageSpeed,
    @HiveField(16) super.routePoints,
    @HiveField(17) super.isPublic,
    @HiveField(18) super.odometer,
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
    bool? isPublic,
    OdometerEntity? odometer,
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
      isPublic: isPublic ?? this.isPublic,
      odometer: odometer ?? this.odometer,
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
      isPublic: data['isPublic'] as bool?,
      odometer: data['odometer'] != null 
          ? OdometerModel.fromFirestore(data['odometer'] as Map<String, dynamic>)
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
      'isPublic': isPublic,
      'odometer': _odometerToFirestore(),
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
      isPublic: json['isPublic'] as bool?,
      odometer: json['odometer'] != null 
          ? OdometerModel.fromJson(json['odometer'] as Map<String, dynamic>)
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
      'isPublic': isPublic,
      'odometer': _odometerToJson(),
    };
  }

  /// 🔹 From Hive
  factory RideModel.fromHive(Map<String, dynamic> hiveData) {
    return RideModel(
      id: hiveData['id'] as String,
      userId: hiveData['userId'] as String,
      vehicleId: hiveData['vehicleId'] as String,
      status: hiveData['status'] as String,
      startedAt: DateTime.fromMillisecondsSinceEpoch(hiveData['startedAt'] as int),
      startCoordinates: GeoPoint(
        hiveData['startLat'] as double,
        hiveData['startLng'] as double,
      ),
      endCoordinates: hiveData['endLat'] != null && hiveData['endLng'] != null
          ? GeoPoint(
              hiveData['endLat'] as double,
              hiveData['endLng'] as double,
            )
          : null,
      endedAt: hiveData['endedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(hiveData['endedAt'] as int) 
          : null,
      totalDistance: hiveData['totalDistance'] as double?,
      totalTime: hiveData['totalTime'] as double?,
      totalGEMCoins: hiveData['totalGEMCoins'] as double?,
      rideMemories: hiveData['rideMemories'] != null
          ? (hiveData['rideMemories'] as List<dynamic>)
              .map((memory) => RideMemoryModel.fromHive(memory as Map<String, dynamic>))
              .toList()
          : null,
      rideTitle: hiveData['rideTitle'] as String?,
      rideDescription: hiveData['rideDescription'] as String?,
      topSpeed: hiveData['topSpeed'] as double?,
      averageSpeed: hiveData['averageSpeed'] as double?,
      routePoints: hiveData['routePoints'] != null
          ? (hiveData['routePoints'] as List<dynamic>)
              .map((point) => GeoPoint(
                point['latitude'] as double,
                point['longitude'] as double,
              ))
              .toList()
          : null,
      isPublic: hiveData['isPublic'] as bool?,
      odometer: hiveData['odometer'] != null 
          ? OdometerModel.fromHive(hiveData['odometer'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 🔹 To Hive
  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'status': status,
      'startedAt': startedAt.millisecondsSinceEpoch,
      'startLat': startCoordinates.latitude,
      'startLng': startCoordinates.longitude,
      'endLat': endCoordinates?.latitude,
      'endLng': endCoordinates?.longitude,
      'endedAt': endedAt?.millisecondsSinceEpoch,
      'totalDistance': totalDistance,
      'totalTime': totalTime,
      'totalGEMCoins': totalGEMCoins,
      'rideMemories': rideMemories?.map((memory) {
        if (memory is RideMemoryModel) {
          return memory.toHive();
        }
        return RideMemoryModel.fromEntity(memory).toHive();
      }).toList(),
      'rideTitle': rideTitle,
      'rideDescription': rideDescription,
      'topSpeed': topSpeed,
      'averageSpeed': averageSpeed,
      'routePoints': routePoints?.map((point) => {
        'latitude': point.latitude,
        'longitude': point.longitude,
      }).toList(),
      'isPublic': isPublic,
      'odometer': _odometerToHive(),
    };
  }

  /// Helper methods for odometer serialization
  Map<String, dynamic>? _odometerToFirestore() {
    if (odometer == null) return null;
    if (odometer is OdometerModel) {
      return (odometer! as OdometerModel).toFirestore();
    } else {
      return OdometerModel.fromEntity(odometer!).toFirestore();
    }
  }

  Map<String, dynamic>? _odometerToJson() {
    if (odometer == null) return null;
    if (odometer is OdometerModel) {
      return (odometer! as OdometerModel).toJson();
    } else {
      return OdometerModel.fromEntity(odometer!).toJson();
    }
  }

  Map<String, dynamic>? _odometerToHive() {
    if (odometer == null) return null;
    if (odometer is OdometerModel) {
      return (odometer! as OdometerModel).toHive();
    } else {
      return OdometerModel.fromEntity(odometer!).toHive();
    }
  }
}
