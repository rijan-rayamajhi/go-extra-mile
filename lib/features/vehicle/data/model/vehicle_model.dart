import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.vehicleType,
    required super.vehicleBrandImage,
    required super.vehicleBrandName,
    required super.vehicleModelName,
    required super.vehicleRegistrationNumber,
    required super.vehicleTyreType,
    required super.verificationStatus,
  });

  /// Convert Firestore document to VehicleModel
  factory VehicleModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      id: doc.id, // Firebase doc id
      vehicleType: data['vehicleType'] ?? '',
      vehicleBrandImage: data['vehicleBrandImage'] ?? '',
      vehicleBrandName: data['vehicleBrandName'] ?? '',
      vehicleModelName: data['vehicleModelName'] ?? '',
      vehicleRegistrationNumber: data['vehicleRegistrationNumber'] ?? '',
      vehicleTyreType: data['vehicleTyreType'] ?? '',
      verificationStatus: _mapVerificationStatus(data['verificationStatus']),
    );
  }

  /// Convert VehicleModel to JSON for Firestore
  Map<String, dynamic> toDocument() {
    return {
      'vehicleType': vehicleType,
      'vehicleBrandImage': vehicleBrandImage,
      'vehicleBrandName': vehicleBrandName,
      'vehicleModelName': vehicleModelName,
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'vehicleTyreType': vehicleTyreType,
      'verificationStatus': verificationStatus.name, // save enum as string
    };
  }

  /// Helper: map string → enum
  static VehicleVerificationStatus _mapVerificationStatus(String? status) {
    switch (status) {
      case 'pending':
        return VehicleVerificationStatus.pending;
      case 'rejected':
        return VehicleVerificationStatus.rejected;
      case 'verified':
        return VehicleVerificationStatus.verified;
      case 'notVerified':
        return VehicleVerificationStatus.notVerified;
      default:
        return VehicleVerificationStatus.notVerified;
    }
  }
}