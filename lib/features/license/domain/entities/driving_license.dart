import 'package:equatable/equatable.dart';

enum VerificationStatus {
  pending,
  rejected,
  verified,
}

class DrivingLicenseEntity extends Equatable {
  final String licenseType;
  final String frontImagePath;
  final String backImagePath;
  final DateTime dob;
  final VerificationStatus verificationStatus;

  const DrivingLicenseEntity({
    required this.licenseType,
    required this.frontImagePath,
    required this.backImagePath,
    required this.dob,
    this.verificationStatus = VerificationStatus.pending,

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