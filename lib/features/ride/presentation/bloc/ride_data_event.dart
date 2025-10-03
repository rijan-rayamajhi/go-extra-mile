import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

abstract class RideDataEvent extends Equatable {
  const RideDataEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllRides extends RideDataEvent {
  const LoadAllRides();
}

class UploadRideEvent extends RideDataEvent {
  final RideEntity ride;

  const UploadRideEvent(this.ride);

  @override
  List<Object?> get props => [ride];
}
