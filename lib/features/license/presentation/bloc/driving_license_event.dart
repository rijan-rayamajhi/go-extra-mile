import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';

abstract class DrivingLicenseEvent extends Equatable {
  const DrivingLicenseEvent();

  @override
  List<Object?> get props => [];
}

class GetDrivingLicenseEvent extends DrivingLicenseEvent {}

class SubmitDrivingLicenseEvent extends DrivingLicenseEvent {
  final DrivingLicenseEntity license;

  const SubmitDrivingLicenseEvent(this.license);

  @override
  List<Object?> get props => [license];
}