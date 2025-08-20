import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/start_ride.dart';
import '../../domain/usecases/get_current_ride.dart';
import '../../domain/usecases/get_all_rides_by_user_id.dart';
import '../../domain/usecases/get_recent_rides_by_user_id.dart';
import '../../domain/usecases/upload_ride.dart';
import '../../domain/usecases/discard_ride.dart';
import '../../domain/usecases/update_ride_fields.dart';
import '../../domain/usecases/get_ride_memories_by_user_id.dart';
import '../../domain/usecases/get_recent_ride_memories_by_user_id.dart';
import 'ride_event.dart';
import 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  final StartRide startRide;
  final GetCurrentRide getCurrentRide;
  final GetAllRidesByUserId getAllRidesByUserId;
  final GetRecentRidesByUserId getRecentRidesByUserId;
  final GetRideMemoriesByUserId getRideMemoriesByUserId;
  final GetRecentRideMemoriesByUserId getRecentRideMemoriesByUserId;
  final UploadRide uploadRide;
  final DiscardRide discardRide;
  final UpdateRideFields updateRideFields;

  RideBloc({
    required this.startRide,
    required this.getCurrentRide,
    required this.getAllRidesByUserId,
    required this.getRecentRidesByUserId,
    required this.getRideMemoriesByUserId,
    required this.getRecentRideMemoriesByUserId,
    required this.uploadRide,
    required this.discardRide,
    required this.updateRideFields,
  }) : super(RideInitial()) {
    on<StartRideEvent>(_onStartRide);
    on<GetCurrentRideEvent>(_onGetCurrentRide);
    on<GetAllRidesByUserIdEvent>(_onGetAllRidesByUserId);
    on<GetRecentRidesByUserIdEvent>(_onGetRecentRidesByUserId);
    on<GetRideMemoriesByUserIdEvent>(_onGetRideMemoriesByUserId);
    on<GetRecentRideMemoriesByUserIdEvent>(_onGetRecentRideMemoriesByUserId);
    on<UploadRideEvent>(_onUploadRide);
    on<DiscardRideEvent>(_onDiscardRide);
    on<UpdateRideFieldsEvent>(_onUpdateRideFields);
  }

  Future<void> _onStartRide(StartRideEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      final ride = await startRide(
        event.rideEntity,
      );
      emit(RideStarted(ride));
    } catch (err) {
      emit(RideFailure('Failed to start ride: ${err.toString()}'));
    }
  }

  Future<void> _onGetCurrentRide(GetCurrentRideEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      final ride = await getCurrentRide(event.userId);
      emit(CurrentRideLoaded(ride));
    } catch (err) {
      emit(RideFailure('Failed to get current ride: ${err.toString()}'));
    }
  }

  Future<void> _onGetAllRidesByUserId(GetAllRidesByUserIdEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      final rides = await getAllRidesByUserId(event.userId);
      emit(AllRidesLoaded(rides));
    } catch (err) {
      emit(RideFailure('Failed to get rides: ${err.toString()}'));
    }
  }

  Future<void> _onGetRecentRidesByUserId(GetRecentRidesByUserIdEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      final rides = await getRecentRidesByUserId(event.userId, limit: event.limit);
      emit(RecentRidesLoaded(rides, event.limit));
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

  Future<void> _onDiscardRide(DiscardRideEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      await discardRide(event.userId);
      emit(RideDiscarded());
    } catch (err) {
      emit(RideFailure('Failed to discard ride: ${err.toString()}'));
    }
  }

  Future<void> _onUpdateRideFields(UpdateRideFieldsEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      await updateRideFields(event.userId, event.fields);
      emit(RideFieldsUpdated(
        userId: event.userId,
        updatedFields: event.fields,
      ));
    } catch (err) {
      emit(RideFailure('Failed to update ride fields: ${err.toString()}'));
    }
  }

  Future<void> _onGetRideMemoriesByUserId(GetRideMemoriesByUserIdEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      final memories = await getRideMemoriesByUserId(event.userId);
      emit(RideMemoriesLoaded(memories));
    } catch (err) {
      emit(RideFailure('Failed to get ride memories: ${err.toString()}'));
    }
  }

  Future<void> _onGetRecentRideMemoriesByUserId(GetRecentRideMemoriesByUserIdEvent event, Emitter emit) async {
    emit(RideLoading());
    try {
      final memories = await getRecentRideMemoriesByUserId(event.userId, limit: event.limit);
      emit(RecentRideMemoriesLoaded(memories, event.limit));
    } catch (err) {
      emit(RideFailure('Failed to get recent ride memories: ${err.toString()}'));
    }
  }
} 