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

  final List<String>? vehicleSlideImages;
  final String? vehicleInsuranceImage;
  final String? vehicleFrontImage;
  final String? vehicleBackImage;
  final String? vehicleRCFrontImage;
  final String? vehicleRCBackImage;


  const VehicleEntity({
    required this.id,
    required this.vehicleType,
    required this.vehicleBrandImage,
    required this.vehicleBrandName,
    required this.vehicleModelName,
    required this.vehicleRegistrationNumber,
    required this.vehicleTyreType,
    required this.verificationStatus,
    this.vehicleSlideImages,
    this.vehicleInsuranceImage,
    this.vehicleFrontImage,
    this.vehicleBackImage,
    this.vehicleRCFrontImage,
    this.vehicleRCBackImage,
  });

  VehicleEntity copyWith({
    String? id,
    String? vehicleType,
    String? vehicleBrandImage,
    String? vehicleBrandName,
    String? vehicleModelName,
    String? vehicleRegistrationNumber,
    String? vehicleTyreType,
    VehicleVerificationStatus? verificationStatus,
    List<String>? vehicleSlideImages,
    String? vehicleInsuranceImage,
    String? vehicleFrontImage,
    String? vehicleBackImage,
    String? vehicleRCFrontImage,
    String? vehicleRCBackImage,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleBrandImage: vehicleBrandImage ?? this.vehicleBrandImage,
      vehicleBrandName: vehicleBrandName ?? this.vehicleBrandName,
      vehicleModelName: vehicleModelName ?? this.vehicleModelName,
      vehicleRegistrationNumber: vehicleRegistrationNumber ?? this.vehicleRegistrationNumber,
      vehicleTyreType: vehicleTyreType ?? this.vehicleTyreType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      vehicleSlideImages: vehicleSlideImages ?? this.vehicleSlideImages,
      vehicleInsuranceImage: vehicleInsuranceImage ?? this.vehicleInsuranceImage,
      vehicleFrontImage: vehicleFrontImage ?? this.vehicleFrontImage,
      vehicleBackImage: vehicleBackImage ?? this.vehicleBackImage,
      vehicleRCFrontImage: vehicleRCFrontImage ?? this.vehicleRCFrontImage,
      vehicleRCBackImage: vehicleRCBackImage ?? this.vehicleRCBackImage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleType,
        vehicleBrandImage,
        vehicleBrandName,
        vehicleModelName,
        vehicleRegistrationNumber,
        vehicleTyreType,
        verificationStatus,
        vehicleSlideImages,
        vehicleInsuranceImage,
        vehicleFrontImage,
        vehicleBackImage,
        vehicleRCFrontImage,
        vehicleRCBackImage,
      ];
}