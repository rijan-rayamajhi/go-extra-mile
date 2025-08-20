import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';

class RideEntity extends Equatable {
  // 🔹 Identity
  final String id;
  final String userId;
  final String vehicleId;
  final String status;
  final DateTime startedAt;
  final GeoPoint startCoordinates;
  final GeoPoint? endCoordinates;
  final DateTime? endedAt;
  final double? totalDistance;
  final double? totalTime;
  final double? totalGEMCoins;
  final List<RideMemoryEntity>? rideMemories;

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
      ];
}
