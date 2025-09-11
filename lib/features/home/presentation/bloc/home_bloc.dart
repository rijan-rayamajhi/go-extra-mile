import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/home/domain/usecases/get_user_profile_image.dart';
import 'package:go_extra_mile_new/features/home/domain/usecases/get_unread_notification.dart';
import 'package:go_extra_mile_new/features/home/domain/usecases/get_unverified_vehicle.dart';
import 'package:go_extra_mile_new/features/home/domain/usecases/get_recent_rides.dart'
    as recent_rides;
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProfileImage getUserProfileImage;
  final GetUnreadNotification getUnreadNotification;
  final GetUnverifiedVehicle getUnverifiedVehicle;
  final recent_rides.GetRecentRidesUseCase getRecentRides;

  HomeBloc({
    required this.getUserProfileImage,
    required this.getUnreadNotification,
    required this.getUnverifiedVehicle,
    required this.getRecentRides,
  }) : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      // Load all home data in parallel
      final userProfileImage = await getUserProfileImage();
      final unreadNotificationCount = await getUnreadNotification();
      final unverifiedVehicleCount = await getUnverifiedVehicle();
      final rideData = await getRecentRides();
      final remoteRides = rideData['remoteRides'] as List;
      final localRides = rideData['localRides'] as List;

      emit(
        HomeLoaded(
          userProfileImage: userProfileImage,
          unreadNotificationCount: unreadNotificationCount,
          unverifiedVehicleCount: unverifiedVehicleCount,
          remoteRides: remoteRides.cast(),
          localRides: localRides.cast(),
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to load home data: $e'));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(isRefreshing: true));
    } else {
      emit(const HomeLoading());
    }

    try {
      // Load all home data in parallel
      final userProfileImage = await getUserProfileImage();
      final unreadNotificationCount = await getUnreadNotification();
      final unverifiedVehicleCount = await getUnverifiedVehicle();
      final rideData = await getRecentRides();
      final remoteRides = rideData['remoteRides'] as List;
      final localRides = rideData['localRides'] as List;

      emit(
        HomeLoaded(
          userProfileImage: userProfileImage,
          unreadNotificationCount: unreadNotificationCount,
          unverifiedVehicleCount: unverifiedVehicleCount,
          isRefreshing: false,
          remoteRides: remoteRides.cast(),
          localRides: localRides.cast(),
        ),
      );
    } catch (e) {
      emit(HomeError('Failed to refresh home data: $e'));
    }
  }
}
