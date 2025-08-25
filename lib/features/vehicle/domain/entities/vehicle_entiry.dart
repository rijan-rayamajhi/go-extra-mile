import 'package:equatable/equatable.dart';

enum VehicleVerificationStatus {
  pending,
  rejected,
  verified,
  notVerified
}

class VehicleEntity extends Equatable {
  final String id;
  final String vehicleType;
  final String vehicleBrandImage;
  final String vehicleBrandName;
  final String vehicleModelName;
  final String vehicleRegistrationNumber;
  final String vehicleTyreType;
  final VehicleVerificationStatus verificationStatus;

  const VehicleEntity({
    required this.id,
    required this.vehicleType,
    required this.vehicleBrandImage,
    required this.vehicleBrandName,
    required this.vehicleModelName,
    required this.vehicleRegistrationNumber,
    required this.vehicleTyreType,
    required this.verificationStatus,
  });

  @override
  List<Object?> get props => [id, vehicleType, vehicleBrandImage, vehicleBrandName, vehicleModelName, vehicleRegistrationNumber, vehicleTyreType, verificationStatus];
}