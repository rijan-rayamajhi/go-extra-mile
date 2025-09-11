import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final String? userProfileImage;
  final String unreadNotificationCount;
  final String unverifiedVehicleCount;
  final List<RideEntity> remoteRides;
  final List<RideEntity> localRides;
  final bool isRefreshing;

  const HomeLoaded({
    this.userProfileImage,
    required this.unreadNotificationCount,
    required this.unverifiedVehicleCount,
    this.remoteRides = const [],
    this.localRides = const [],
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
        userProfileImage,
        unreadNotificationCount,
        unverifiedVehicleCount,
        remoteRides,
        localRides,
        isRefreshing,
      ];

  HomeLoaded copyWith({
    String? userProfileImage,
    String? unreadNotificationCount,
    String? unverifiedVehicleCount,
    List<RideEntity>? remoteRides,
    List<RideEntity>? localRides,
    bool? isRefreshing,
  }) {
    return HomeLoaded(
      userProfileImage: userProfileImage ?? this.userProfileImage,
      unreadNotificationCount: unreadNotificationCount ?? this.unreadNotificationCount,
      unverifiedVehicleCount: unverifiedVehicleCount ?? this.unverifiedVehicleCount,
      remoteRides: remoteRides ?? this.remoteRides,
      localRides: localRides ?? this.localRides,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
