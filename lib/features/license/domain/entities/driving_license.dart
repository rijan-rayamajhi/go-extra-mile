import 'package:equatable/equatable.dart';

enum DrivingLicenseVerificationStatus {
  pending,
  rejected,
  verified
}

class DrivingLicenseEntity extends Equatable {
  final String licenseType;
  final String frontImagePath;
  final String backImagePath;
  final DateTime dob;
  final DrivingLicenseVerificationStatus verificationStatus;

  const DrivingLicenseEntity({
    required this.licenseType,
    required this.frontImagePath,
    required this.backImagePath,
    required this.dob,
    this.verificationStatus = DrivingLicenseVerificationStatus.pending,

  });

  @override
  List<Object?> get props => [
        licenseType,
        frontImagePath,
        backImagePath,
        dob,
        verificationStatus,
      ];
} 