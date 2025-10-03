import 'package:equatable/equatable.dart';
import '../../domain/entities/ride_entity.dart';

class RideState extends Equatable {
  final bool isTracking;
  final RideEntity? ride;
  final List<RideEntity> localRides;
  final List<RideEntity> remoteRides;
  final RideEntity? currentRide;
  final String? uploadError;

  const RideState({
    this.isTracking = false,
    this.currentRide,
    this.localRides = const [],
    this.remoteRides = const [],
    this.ride,
    this.uploadError,
  });

  /// 🔹 CopyWith
  RideState copyWith({
    bool? isTracking,
    RideEntity? currentRide,
    List<RideEntity>? localRides,
    List<RideEntity>? remoteRides,
    RideEntity? ride,
    String? uploadError,
  }) {
    return RideState(
      isTracking: isTracking ?? this.isTracking,
      currentRide: currentRide ?? this.currentRide,
      localRides: localRides ?? this.localRides,
      remoteRides: remoteRides ?? this.remoteRides,
      ride: ride ?? this.ride,
      uploadError: uploadError ?? this.uploadError,
    );
  }

  /// 🔹 Initial empty state
  factory RideState.initial() => const RideState();

  @override
  List<Object?> get props => [
    isTracking,
    currentRide,
    localRides,
    remoteRides,
    ride,
    uploadError,
  ];
}
