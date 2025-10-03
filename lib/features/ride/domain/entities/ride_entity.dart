import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'odometer_entity.dart';
import 'ride_memory_entity.dart';

class RideEntity extends Equatable {
  // 🔹 Identity
  final String? id;
  final String? userId;
  final String? vehicleId;
  final String? status;
  final DateTime? startedAt;
  final GeoPoint? startCoordinates;
  final GeoPoint? endCoordinates;
  final DateTime? endedAt;
  final double? totalDistance;
  final double? totalTime;
  final double? totalGEMCoins;
  final List<RideMemoryEntity>? rideMemories;

  // 🔹 Ride Details
  final String? rideTitle;
  final String? rideDescription;
  final double? topSpeed;
  final double? averageSpeed;
  final List<GeoPoint>? routePoints;
  final bool? isPublic;

  // 🔹 Odometer
  final OdometerEntity? odometer;

  const RideEntity({
    this.id,
    this.userId,
    this.vehicleId,
    this.status,
    this.startedAt,
    this.startCoordinates,
    this.endCoordinates,
    this.endedAt,
    this.totalDistance,
    this.totalTime,
    this.totalGEMCoins,
    this.rideMemories,
    this.rideTitle,
    this.rideDescription,
    this.topSpeed,
    this.averageSpeed,
    this.routePoints,
    this.isPublic,
    this.odometer,
  });

  /// 🔹 CopyWith
  RideEntity copyWith({
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
    return RideEntity(
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

  @override
  List<Object?> get props => [
    id,
    userId,
    vehicleId,
    status,
    startedAt,
    startCoordinates,
    endCoordinates,
    endedAt,
    totalDistance,
    totalTime,
    totalGEMCoins,
    rideMemories,
    rideTitle,
    rideDescription,
    topSpeed,
    averageSpeed,
    routePoints,
    isPublic,
    odometer,
  ];
}
