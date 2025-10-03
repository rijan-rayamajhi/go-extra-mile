import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/ride/domain/usecases/get_all_firebase_rides.dart';
import 'package:go_extra_mile_new/features/ride/domain/usecases/get_all_hive_rides.dart';
import 'package:go_extra_mile_new/features/ride/domain/usecases/get_recent_ride.dart';
import 'package:go_extra_mile_new/features/ride/domain/usecases/get_ride_by_id.dart';
import 'package:go_extra_mile_new/features/ride/domain/usecases/upload_ride.dart';
import 'ride_data_event.dart';
import 'ride_data_state.dart';

class RideDataBloc extends Bloc<RideDataEvent, RideDataState> {
  final GetAllFirebaseRides getAllFirebaseRides;
  final GetAllHiveRides getAllHiveRides;
  final GetRecentRide getRecentRide;
  final GetRideById getRideById;
  final UploadRide uploadRide;

  RideDataBloc({
    required this.getAllFirebaseRides,
    required this.getAllHiveRides,
    required this.getRecentRide,
    required this.getRideById,
    required this.uploadRide,
  }) : super(const RideDataInitial()) {
    on<LoadAllRides>(_onLoadAllRides);
    on<UploadRideEvent>(_onUploadRide);
  }

  Future<void> _onLoadAllRides(
    LoadAllRides event,
    Emitter<RideDataState> emit,
  ) async {
    emit(const RideDataLoading());
    try {
      // Load from both Firebase (remote) and Hive (local)
      final remoteRides = await getAllFirebaseRides();
      final localRides = await getAllHiveRides();
      final recentRide = await getRecentRide();

      emit(
        RideDataLoaded(
          localRides: localRides,
          remoteRides: remoteRides,
          recentRide: recentRide,
        ),
      );
    } catch (e) {
      emit(RideDataError(e.toString()));
    }
  }

  Future<void> _onUploadRide(
    UploadRideEvent event,
    Emitter<RideDataState> emit,
  ) async {
    emit(const RideDataLoading());
    try {
      await uploadRide(event.ride);
      
      // Reload all rides after successful upload
      final remoteRides = await getAllFirebaseRides();
      final localRides = await getAllHiveRides();
      final recentRide = await getRecentRide();

      emit(
        RideDataLoaded(
          localRides: localRides,
          remoteRides: remoteRides,
          recentRide: recentRide,
        ),
      );
    } catch (e) {
      emit(RideDataError(e.toString()));
    }
  }
}
