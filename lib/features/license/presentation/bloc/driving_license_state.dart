import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';

abstract class DrivingLicenseState extends Equatable {
  const DrivingLicenseState();

  @override
  List<Object?> get props => [];
}

class DrivingLicenseInitial extends DrivingLicenseState {}

class DrivingLicenseLoading extends DrivingLicenseState {}

class DrivingLicenseLoaded extends DrivingLicenseState {
  final DrivingLicenseEntity? license;

  const DrivingLicenseLoaded(this.license);

  @override
  List<Object?> get props => [license];
}

class DrivingLicenseError extends DrivingLicenseState {
  final String message;

  const DrivingLicenseError(this.message);

  @override
  List<Object?> get props => [message];
}

class DrivingLicenseSubmitted extends DrivingLicenseState {
  final DrivingLicenseEntity license;

  const DrivingLicenseSubmitted(this.license);

  @override
  List<Object?> get props => [license];
}