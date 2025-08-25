
// ------------------- States -------------------
import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<VehicleEntity> vehicles;

  const VehicleLoaded(this.vehicles);

  @override
  List<Object?> get props => [vehicles];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}

class VehicleAdded extends VehicleState {}

