import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/core/service/firebase_storage_service.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';
import 'package:go_extra_mile_new/features/license/domain/repositories/driving_license_repository.dart';
import 'package:go_extra_mile_new/features/license/data/models/driving_license_model.dart';

class DrivingLicenseRepositoryImpl implements DrivingLicenseRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final FirebaseStorageService storageService;

  DrivingLicenseRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorageService? storageService,
  })  : firestore = firestore ?? FirebaseFirestore.instance,
        auth = auth ?? FirebaseAuth.instance,
        storageService = storageService ?? FirebaseStorageService();

  final String fieldName = "drivingLicenses"; // Field name within user document

  /// Helper to get current UID
  String get _uid {
    final user = auth.currentUser;
    if (user == null) throw Exception("User not logged in");
    return user.uid;
  }

  @override
  Future<Either<Failure, DrivingLicenseEntity>> getDrivingLicense() async {
    try {
      final doc = await firestore.collection('users').doc(_uid).get();

      if (!doc.exists) {
        return Left(ServerFailure("User document not found"));
      }

      final data = doc.data();
      if (data == null || !data.containsKey(fieldName)) {
        return Left(ServerFailure("No Driving License found for user"));
      }

      final license = DrivingLicenseModel.fromMap(data[fieldName]);
      return Right(license);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DrivingLicenseEntity>> submitDrivingLicense(
      DrivingLicenseEntity license) async {
    try {
      // Handle front image - upload if it's a local file, keep URL if it's already a network image
      String frontImageUrl = '';
      if (license.frontImagePath.isNotEmpty) {
        // Check if it's a local file path or network URL
        if (license.frontImagePath.startsWith('http://') || 
            license.frontImagePath.startsWith('https://')) {
          // It's already a network image URL, keep it as is
          frontImageUrl = license.frontImagePath;
        } else {
          // It's a local file path, upload it
          final frontFile = File(license.frontImagePath);
          if (await frontFile.exists()) {
            final frontPath = 'driving_licenses/${_uid}/front_${DateTime.now().millisecondsSinceEpoch}.jpg';
            frontImageUrl = await storageService.uploadFile(
              file: frontFile,
              path: frontPath,
            );
          }
        }
      }

      // Handle back image - upload if it's a local file, keep URL if it's already a network image
      String backImageUrl = '';
      if (license.backImagePath.isNotEmpty) {
        // Check if it's a local file path or network URL
        if (license.backImagePath.startsWith('http://') || 
            license.backImagePath.startsWith('https://')) {
          // It's already a network image URL, keep it as is
          backImageUrl = license.backImagePath;
        } else {
          // It's a local file path, upload it
          final backFile = File(license.backImagePath);
          if (await backFile.exists()) {
            final backPath = 'driving_licenses/${_uid}/back_${DateTime.now().millisecondsSinceEpoch}.jpg';
            backImageUrl = await storageService.uploadFile(
              file: backFile,
              path: backPath,
            );
          }
        }
      }

      // Create model with download URLs instead of file paths
      final model = DrivingLicenseModel(
        licenseType: license.licenseType,
        frontImagePath: frontImageUrl, // Now contains the download URL
        backImagePath: backImageUrl,   // Now contains the download URL
        dob: license.dob,
        verificationStatus: license.verificationStatus,
      );

      await firestore
          .collection('users')
          .doc(_uid)
          .update({fieldName: model.toMap()});

      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}