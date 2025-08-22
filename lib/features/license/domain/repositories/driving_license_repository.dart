import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';

abstract class DrivingLicenseRepository {
  Future<Either<Failure, DrivingLicenseEntity>> submitDrivingLicense(DrivingLicenseEntity license);
  Future<Either<Failure, DrivingLicenseEntity>> getDrivingLicense();
} 