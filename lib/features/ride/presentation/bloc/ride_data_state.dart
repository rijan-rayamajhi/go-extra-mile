import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

abstract class RideDataState extends Equatable {
  const RideDataState();

  @override
  List<Object?> get props => [];
}

class RideDataInitial extends RideDataState {
  const RideDataInitial();
}

class RideDataLoading extends RideDataState {
  const RideDataLoading();
}

class RideDataLoaded extends RideDataState {
  final List<RideEntity>? localRides;
  final List<RideEntity>? remoteRides;
  final RideEntity? recentRide;

  const RideDataLoaded({this.localRides, this.remoteRides, this.recentRide});
  @override
  List<Object?> get props => [localRides, remoteRides, recentRide];
}

class RideDataError extends RideDataState {
  final String message;

  const RideDataError(this.message);

  @override
  List<Object?> get props => [message];
}
