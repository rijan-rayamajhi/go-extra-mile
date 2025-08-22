import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';
import 'package:go_extra_mile_new/features/license/domain/repositories/driving_license_repository.dart';

class GetDrivingLicense {
  final DrivingLicenseRepository repository;

  GetDrivingLicense(this.repository);

  Future<Either<Failure, DrivingLicenseEntity>> call() async {
    return await repository.getDrivingLicense();
  }
}