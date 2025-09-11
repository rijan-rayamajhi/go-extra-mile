import 'dart:io';

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

class UploadVehicleImage extends VehicleEvent {
  final String vehicleId;
  final String userId;
  final File imageFile;
  final String fieldName;

  const UploadVehicleImage(
    this.vehicleId,
    this.userId,
    this.imageFile,
    this.fieldName,
  );

  @override
  List<Object?> get props => [vehicleId, userId, imageFile, fieldName];
}

class DeleteVehicleImage extends VehicleEvent {
  final String vehicleId;
  final String userId;
  final String fieldName;
  final String imageUrl;

  const DeleteVehicleImage(
    this.vehicleId,
    this.userId,
    this.fieldName,
    this.imageUrl,
  );

  @override
  List<Object?> get props => [vehicleId, userId, fieldName, imageUrl];
}

class VerifyVehicleEvent extends VehicleEvent {
  final String vehicleId;
  final String userId;

  const VerifyVehicleEvent(this.vehicleId, this.userId);

  @override
  List<Object?> get props => [vehicleId, userId];
}