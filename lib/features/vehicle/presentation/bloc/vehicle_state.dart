// ------------------- States -------------------
import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_brand_entity.dart';
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
  final List<VehicleBrandEntity> vehicleBrands;

  const VehicleLoaded(this.vehicles, this.vehicleBrands);

  @override
  List<Object?> get props => [vehicles, vehicleBrands];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}
