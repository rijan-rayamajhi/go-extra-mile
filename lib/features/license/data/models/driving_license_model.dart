import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';

class DrivingLicenseModel extends DrivingLicenseEntity {
  const DrivingLicenseModel({
    required super.licenseType,
    required super.frontImagePath,
    required super.backImagePath,
    required super.dob,
    super.verificationStatus,
  });

  /// Convert Firestore Document -> Model
  factory DrivingLicenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return DrivingLicenseModel(
      licenseType: data['licenseType'] ?? '',
      frontImagePath: data['frontImagePath'] ?? '',
      backImagePath: data['backImagePath'] ?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == (data['verificationStatus'] ?? 'pending'),
        orElse: () => VerificationStatus.pending,
      ),
    );
  }

  /// Convert Map -> Model (for user document field)
  factory DrivingLicenseModel.fromMap(Map<String, dynamic> data) {
    return DrivingLicenseModel(
      licenseType: data['licenseType'] ?? '',
      frontImagePath: data['frontImagePath'] ?? '',
      backImagePath: data['backImagePath'] ?? '',
      dob: (data['dob'] as Timestamp).toDate(),
      verificationStatus: VerificationStatus.values.firstWhere(
        (e) => e.name == (data['verificationStatus'] ?? 'pending'),
        orElse: () => VerificationStatus.pending,
      ),
    );
  }

  /// Convert Model -> Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'licenseType': licenseType,
      'frontImagePath': frontImagePath,
      'backImagePath': backImagePath,
      'dob': Timestamp.fromDate(dob),
      'verificationStatus': verificationStatus.name,
    };
  }
}
