// ------------------- Bloc -------------------
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/add_vehicle.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/get_user_vehicles.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/delete_vehicle.dart'
    as delete_vehicle_usecase;
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/upload_vehicle_image.dart'
    as upload_usecase;
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/delete_vehicle_image.dart'
    as delete_image_usecase;
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/verify_vehicle.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GetUserVehicles getUserVehicles;
  final AddVehicle addVehicle;
  final delete_vehicle_usecase.DeleteVehicle deleteVehicle;
  final upload_usecase.UploadVehicleImage uploadVehicleImage;
  final delete_image_usecase.DeleteVehicleImage deleteVehicleImage;
  final VerifyVehicle verifyVehicle;

  VehicleBloc({
    required this.getUserVehicles,
    required this.addVehicle,
    required this.deleteVehicle,
    required this.uploadVehicleImage,
    required this.deleteVehicleImage,
    required this.verifyVehicle,
  }) : super(VehicleInitial()) {
    // Handle loading vehicles
    on<LoadUserVehicles>((event, emit) async {
      emit(VehicleLoading());
      final Either<Exception, List<VehicleEntity>> result =
          await getUserVehicles(event.userId);

      result.fold(
        (failure) => emit(VehicleError(failure.toString())),
        (vehicles) => emit(VehicleLoaded(vehicles)),
      );
    });

    // Handle adding a new vehicle
    on<AddNewVehicle>((event, emit) async {
      emit(VehicleLoading());
      final Either<Exception, void> result = await addVehicle(
        event.vehicle,
        event.userId,
      );

      await result.fold(
        (failure) async => emit(VehicleError(failure.toString())),
        (_) async {
          // Reload vehicles after adding
          final vehiclesResult = await getUserVehicles(event.userId);
          vehiclesResult.fold(
            (failure) => emit(VehicleError(failure.toString())),
            (vehicles) => emit(VehicleLoaded(vehicles)),
          );
        },
      );
    });

    // Handle deleting a vehicle
    on<DeleteVehicle>((event, emit) async {
      await deleteVehicle(event.vehicleId, event.userId);
      final vehiclesResult = await getUserVehicles(event.userId);
      vehiclesResult.fold(
        (failure) => emit(VehicleError(failure.toString())),
        (vehicles) => emit(VehicleLoaded(vehicles)),
      );
    });

    // Handle uploading a vehicle image
    on<UploadVehicleImage>((event, emit) async {
      await uploadVehicleImage(
        event.vehicleId,
        event.userId,
        event.imageFile,
        event.fieldName,
      );
      final vehiclesResult = await getUserVehicles(event.userId);
      vehiclesResult.fold(
        (failure) => emit(VehicleError(failure.toString())),
        (vehicles) => emit(VehicleLoaded(vehicles)),
      );
    });

    // Handle deleting vehicle image
    on<DeleteVehicleImage>((event, emit) async {
      await deleteVehicleImage(
        event.vehicleId,
        event.userId,
        event.fieldName,
        event.imageUrl,
      );
      final vehiclesResult = await getUserVehicles(event.userId);
      vehiclesResult.fold(
        (failure) => emit(VehicleError(failure.toString())),
        (vehicles) => emit(VehicleLoaded(vehicles)),
      );
    });

    // Handle vehicle verification
    on<VerifyVehicleEvent>((event, emit) async {
      emit(VehicleLoading());
      final Either<Exception, void> result = await verifyVehicle(
        event.vehicleId,
        event.userId,
      );
      final vehiclesResult = await getUserVehicles(event.userId);
      result.fold(
        (failure) => emit(VehicleError(failure.toString())),
        (_) => emit(
          VehicleVerificationSubmitted(
            'Verification submitted successfully!',
          ),
        ),
      );
      vehiclesResult.fold(
        (failure) => emit(VehicleError(failure.toString())),
        (vehicles) => emit(VehicleLoaded(vehicles)),
      );
    });
  }
}
