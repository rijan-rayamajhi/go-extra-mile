
// ------------------- Bloc -------------------
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/add_vehicle.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/get_user_vehicles.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GetUserVehicles getUserVehicles;
  final AddVehicle addVehicle;

  VehicleBloc({
    required this.getUserVehicles,
    required this.addVehicle,
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
      final Either<Exception, void> result =
          await addVehicle(event.vehicle, event.userId);

      result.fold(
        (failure) => emit(VehicleError(failure.toString())),
        (_) => emit(VehicleAdded()),
      );
    });
  }
}