import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';



// ------------------- Events -------------------
abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserVehicles extends VehicleEvent {
  final String userId;

  const LoadUserVehicles(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddNewVehicle extends VehicleEvent {
  final VehicleEntity vehicle;
  final String userId;

  const AddNewVehicle(this.vehicle, this.userId);

  @override
  List<Object?> get props => [vehicle, userId];
}

class DeleteVehicle extends VehicleEvent {
  final String vehicleId;
  final String userId;

  const DeleteVehicle(this.vehicleId, this.userId);

  @override
  List<Object?> get props => [vehicleId, userId];
}

