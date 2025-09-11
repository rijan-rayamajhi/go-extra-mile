import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_rides_by_user_id.dart';
import '../../domain/usecases/get_recent_rides_by_user_id.dart';
import '../../domain/usecases/upload_ride.dart';
import '../../domain/usecases/get_recent_ride_memories_by_user_id.dart';
import '../../domain/usecases/save_ride_locally.dart';
import '../../domain/usecases/get_ride_locally.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final GetAllRidesByUserId getAllRidesByUserId;
  final GetRecentRidesByUserId getRecentRidesByUserId;
  final GetRecentRideMemoriesByUserId getRecentRideMemoriesByUserId;
  final UploadRide uploadRide;
  final SaveRideLocally saveRideLocally;
  final GetRideLocally getRideLocally;

  RideBloc({
    required this.getAllRidesByUserId,
    required this.getRecentRidesByUserId,
    required this.getRecentRideMemoriesByUserId,
    required this.uploadRide,
    required this.saveRideLocally,
    required this.getRideLocally,
  }) : super(RideInitial()) {
    on<GetAllRidesByUserIdEvent>(_onGetAllRidesByUserId);
    on<GetRecentRidesByUserIdEvent>(_onGetRecentRidesByUserId);
    on<UploadRideEvent>(_onUploadRide);
    on<SaveRideLocallyEvent>(_onSaveRideLocally);
  }


  Future<void> _onGetAllRidesByUserId(GetAllRidesByUserIdEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      // Fetch both remote and local rides
      final rides = await getAllRidesByUserId(event.userId);
      final localRides = await getRideLocally(event.userId);
      emit(AllRidesLoaded(rides, localRides: localRides));
    } catch (err) {
      emit(RideFailure('Failed to get rides: ${err.toString()}'));
    }
  }

  Future<void> _onGetRecentRidesByUserId(GetRecentRidesByUserIdEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      // Fetch both remote and local rides
      final rides = await getRecentRidesByUserId(event.userId, limit: event.limit);
      final localRides = await getRideLocally(event.userId);
      emit(RecentRidesLoaded(rides, event.limit, localRides: localRides));
    } catch (err) {
      emit(RideFailure('Failed to get recent rides: ${err.toString()}'));
    }
  }

  Future<void> _onUploadRide(UploadRideEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      await uploadRide(event.rideEntity);
      emit(RideUploaded());
    } catch (err) {
      emit(RideFailure('Failed to upload ride: ${err.toString()}'));
    }
  }

  Future<void> _onSaveRideLocally(SaveRideLocallyEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      await saveRideLocally(event.rideEntity);
      emit(RideUploaded());
    } catch (err) {
      emit(RideFailure('Failed to save ride locally: ${err.toString()}'));
    }
  }
} 