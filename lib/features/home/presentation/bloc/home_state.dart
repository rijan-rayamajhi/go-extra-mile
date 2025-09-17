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
  final int totalGemCoins;
  final double totalDistance;
  final int totalRides;
  final String referralCode;

  const HomeLoaded({
    this.userProfileImage,
    required this.unreadNotificationCount,
    required this.unverifiedVehicleCount,
    this.remoteRides = const [],
    this.localRides = const [],
    this.isRefreshing = false,
    this.totalGemCoins = 0,
    this.totalDistance = 0.0,
    this.totalRides = 0,
    this.referralCode = '',
  });

  @override
  List<Object?> get props => [
        userProfileImage,
        unreadNotificationCount,
        unverifiedVehicleCount,
        remoteRides,
        localRides,
        isRefreshing,
        totalGemCoins,
        totalDistance,
        totalRides,
        referralCode,
      ];

  HomeLoaded copyWith({
    String? userProfileImage,
    String? unreadNotificationCount,
    String? unverifiedVehicleCount,
    List<RideEntity>? remoteRides,
    List<RideEntity>? localRides,
    bool? isRefreshing,
    int? totalGemCoins,
    double? totalDistance,
    int? totalRides,
    String? referralCode,
  }) {
    return HomeLoaded(
      userProfileImage: userProfileImage ?? this.userProfileImage,
      unreadNotificationCount: unreadNotificationCount ?? this.unreadNotificationCount,
      unverifiedVehicleCount: unverifiedVehicleCount ?? this.unverifiedVehicleCount,
      remoteRides: remoteRides ?? this.remoteRides,
      localRides: localRides ?? this.localRides,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      totalGemCoins: totalGemCoins ?? this.totalGemCoins,
      totalDistance: totalDistance ?? this.totalDistance,
      totalRides: totalRides ?? this.totalRides,
      referralCode: referralCode ?? this.referralCode,
    );
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
