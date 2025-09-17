import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/odometer_entity.dart';

part 'ride_entity.g.dart';

@HiveType(typeId: 2)
class RideEntity extends Equatable {
  // 🔹 Identity
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String vehicleId;
  @HiveField(3)
  final String status;
  @HiveField(4)
  final DateTime startedAt;
  @HiveField(5)
  final GeoPoint startCoordinates;
  @HiveField(6)
  final GeoPoint? endCoordinates;
  @HiveField(7)
  final DateTime? endedAt;
  @HiveField(8)
  final double? totalDistance;
  @HiveField(9)
  final double? totalTime;
  @HiveField(10)
  final double? totalGEMCoins;
  @HiveField(11)
  final List<RideMemoryEntity>? rideMemories;
  
  // 🔹 Ride Details
  @HiveField(12)
  final String? rideTitle;
  @HiveField(13)
  final String? rideDescription;
  @HiveField(14)
  final double? topSpeed;
  @HiveField(15)
  final double? averageSpeed;
  @HiveField(16)
  final List<GeoPoint>? routePoints;
  @HiveField(17)
  final bool? isPublic;
  
  // 🔹 Odometer
  @HiveField(18)
  final OdometerEntity? odometer;

  // ride / docid

  const RideEntity({
    required this.id,
    required this.userId, 
    required this.vehicleId,
    required this.status,
    required this.startedAt,
    required this.startCoordinates,
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
