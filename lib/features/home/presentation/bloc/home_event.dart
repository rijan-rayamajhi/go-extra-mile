import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

class GetRecentRides extends HomeEvent {
  final String userId;
  final int limit;

  const GetRecentRides({
    required this.userId,
    this.limit = 1,
  });

  @override
  List<Object?> get props => [userId, limit];
}