import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/odometer_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import '../../domain/entities/ride_entity.dart';
import 'ride_memory_model.dart';
import 'odometer_model.dart';

class RideModel extends RideEntity {
  const RideModel({
    super.id,
    super.userId,
    super.vehicleId,
    super.status,
    super.startedAt,
    super.startCoordinates,
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
    super.isPublic,
    super.odometer,
  });

  /// Create from Firestore
  factory RideModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return RideModel(
      id: doc.id,
      userId: data['userId'] as String?,
      vehicleId: data['vehicleId'] as String?,
      status: data['status'] as String?,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      startCoordinates: data['startCoordinates'] as GeoPoint?,
      endCoordinates: data['endCoordinates'] as GeoPoint?,
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      totalDistance: (data['totalDistance'] as num?)?.toDouble(),
      totalTime: (data['totalTime'] as num?)?.toDouble(),
      totalGEMCoins: (data['totalGEMCoins'] as num?)?.toDouble(),
      rideMemories: data['rideMemories'] != null
          ? (data['rideMemories'] as List<dynamic>)
                .map((e) => RideMemoryModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      rideTitle: data['rideTitle'] as String?,
      rideDescription: data['rideDescription'] as String?,
      topSpeed: (data['topSpeed'] as num?)?.toDouble(),
      averageSpeed: (data['averageSpeed'] as num?)?.toDouble(),
      routePoints: data['routePoints'] != null
          ? (data['routePoints'] as List<dynamic>)
                .map((e) {
                  if (e is GeoPoint) {
                    return e;
                  } else if (e is Map<String, dynamic>) {
                    return GeoPoint(
                      (e['latitude'] as num).toDouble(),
                      (e['longitude'] as num).toDouble(),
                    );
                  }
                  throw Exception('Invalid routePoint type: ${e.runtimeType}');
                })
                .toList()
          : null,
      isPublic: data['isPublic'] as bool?,
      odometer: data['odometer'] != null
          ? OdometerModel.fromJson(data['odometer'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (status != null) 'status': status,
      if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt!),
      if (startCoordinates != null) 'startCoordinates': startCoordinates,
      if (endCoordinates != null) 'endCoordinates': endCoordinates,
      if (endedAt != null) 'endedAt': Timestamp.fromDate(endedAt!),
      if (totalDistance != null) 'totalDistance': totalDistance,
      if (totalTime != null) 'totalTime': totalTime,
      if (totalGEMCoins != null) 'totalGEMCoins': totalGEMCoins,
      if (rideMemories != null)
        'rideMemories': rideMemories!
            .map(
              (e) => e is RideMemoryModel
                  ? e.toJson()
                  : RideMemoryModel.fromEntity(e).toJson(),
            )
            .toList(),
      if (rideTitle != null) 'rideTitle': rideTitle,
      if (rideDescription != null) 'rideDescription': rideDescription,
      if (topSpeed != null) 'topSpeed': topSpeed,
      if (averageSpeed != null) 'averageSpeed': averageSpeed,
      if (routePoints != null)
        'routePoints': routePoints!
            .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
            .toList(),
      if (isPublic != null) 'isPublic': isPublic,
      if (odometer != null)
        'odometer': odometer is OdometerModel
            ? (odometer as OdometerModel).toJson()
            : OdometerModel.fromEntity(odometer).toJson(),
    };
  }

  /// JSON for Hive
  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      status: json['status'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'])
          : null,
      startCoordinates: json['startCoordinates'] != null
          ? GeoPoint(
              (json['startCoordinates']['latitude'] as num).toDouble(),
              (json['startCoordinates']['longitude'] as num).toDouble(),
            )
          : null,
      endCoordinates: json['endCoordinates'] != null
          ? GeoPoint(
              (json['endCoordinates']['latitude'] as num).toDouble(),
              (json['endCoordinates']['longitude'] as num).toDouble(),
            )
          : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      totalDistance: (json['totalDistance'] as num?)?.toDouble(),
      totalTime: (json['totalTime'] as num?)?.toDouble(),
      totalGEMCoins: (json['totalGEMCoins'] as num?)?.toDouble(),
      rideMemories: json['rideMemories'] != null
          ? (json['rideMemories'] as List<dynamic>)
                .map((e) => RideMemoryModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      rideTitle: json['rideTitle'] as String?,
      rideDescription: json['rideDescription'] as String?,
      topSpeed: (json['topSpeed'] as num?)?.toDouble(),
      averageSpeed: (json['averageSpeed'] as num?)?.toDouble(),
      routePoints: json['routePoints'] != null
          ? (json['routePoints'] as List<dynamic>)
                .map(
                  (e) => GeoPoint(
                    (e['latitude'] as num).toDouble(),
                    (e['longitude'] as num).toDouble(),
                  ),
                )
                .toList()
          : null,
      isPublic: json['isPublic'] as bool?,
      odometer: json['odometer'] != null
          ? OdometerModel.fromJson(json['odometer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'status': status,
      'startedAt': startedAt?.toIso8601String(),
      'startCoordinates': startCoordinates != null
          ? {
              'latitude': startCoordinates!.latitude,
              'longitude': startCoordinates!.longitude,
            }
          : null,
      'endCoordinates': endCoordinates != null
          ? {
              'latitude': endCoordinates!.latitude,
              'longitude': endCoordinates!.longitude,
            }
          : null,
      'endedAt': endedAt?.toIso8601String(),
      'totalDistance': totalDistance,
      'totalTime': totalTime,
      'totalGEMCoins': totalGEMCoins,
      'rideMemories': rideMemories
          ?.map(
            (e) => e is RideMemoryModel
                ? e.toJson()
                : RideMemoryModel.fromEntity(e).toJson(),
          )
          .toList(),
      'rideTitle': rideTitle,
      'rideDescription': rideDescription,
      'topSpeed': topSpeed,
      'averageSpeed': averageSpeed,
      'routePoints': routePoints
          ?.map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
          .toList(),
      'isPublic': isPublic,
      'odometer': odometer is OdometerModel
          ? (odometer as OdometerModel).toJson()
          : OdometerModel.fromEntity(odometer).toJson(),
    };
  }

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

  RideEntity toEntity() => this;

  static RideModel fromEntity(RideEntity? entity) => RideModel(
    id: entity?.id,
    userId: entity?.userId,
    vehicleId: entity?.vehicleId,
    status: entity?.status,
    startedAt: entity?.startedAt,
    startCoordinates: entity?.startCoordinates,
    endCoordinates: entity?.endCoordinates,
    endedAt: entity?.endedAt,
    totalDistance: entity?.totalDistance,
    totalTime: entity?.totalTime,
    totalGEMCoins: entity?.totalGEMCoins,
    rideMemories: entity?.rideMemories,
    rideTitle: entity?.rideTitle,
    rideDescription: entity?.rideDescription,
    topSpeed: entity?.topSpeed,
    averageSpeed: entity?.averageSpeed,
    routePoints: entity?.routePoints,
    isPublic: entity?.isPublic,
    odometer: entity?.odometer,
  );
}
