import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';
import 'package:go_extra_mile_new/features/license/domain/repositories/driving_license_repository.dart';

class SubmitDrivingLicense {
  final DrivingLicenseRepository repository;

  SubmitDrivingLicense(this.repository);

  Future<Either<Failure, DrivingLicenseEntity>> call(DrivingLicenseParams params) async {
    return await repository.submitDrivingLicense(params.license);
  }
}

class DrivingLicenseParams extends Equatable {
  final DrivingLicenseEntity license;

  const DrivingLicenseParams({
    required this.license,
  });

  @override
  List<Object> get props => [license];
} 