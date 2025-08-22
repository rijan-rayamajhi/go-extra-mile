import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/license/domain/usecases/get_driving_license.dart';
import 'package:go_extra_mile_new/features/license/domain/usecases/submit_driving_license.dart';
import 'driving_license_event.dart';
import 'driving_license_state.dart';

class DrivingLicenseBloc extends Bloc<DrivingLicenseEvent, DrivingLicenseState> {
  final GetDrivingLicense getDrivingLicense;
  final SubmitDrivingLicense submitDrivingLicense;

  DrivingLicenseBloc({
    required this.getDrivingLicense,
    required this.submitDrivingLicense,
  }) : super(DrivingLicenseInitial()) {
    // Fetch license
    on<GetDrivingLicenseEvent>((event, emit) async {
      emit(DrivingLicenseLoading());
      final result = await getDrivingLicense();
      result.fold(
        (failure) => emit(DrivingLicenseError(failure.message)),
        (license) => emit(DrivingLicenseLoaded(license)),
      );
    });

    // Submit license
    on<SubmitDrivingLicenseEvent>((event, emit) async {
      emit(DrivingLicenseLoading());
      final result = await submitDrivingLicense(
        DrivingLicenseParams(license: event.license),
      );
      result.fold(
        (failure) => emit(DrivingLicenseError(failure.message)),
        (license) => emit(DrivingLicenseSubmitted(license)),
      );
    });
  }
}