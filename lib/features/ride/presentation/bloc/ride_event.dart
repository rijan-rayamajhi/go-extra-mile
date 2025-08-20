import 'package:equatable/equatable.dart';

import '../../domain/entities/ride_entity.dart';

abstract class RideEvent extends Equatable {
  @override 
  List<Object?> get props => [];
}

class StartRideEvent extends RideEvent {
  final RideEntity rideEntity;
  
  StartRideEvent({
    required this.rideEntity,
  });
  
  @override
  List<Object?> get props => [rideEntity];
}

class GetCurrentRideEvent extends RideEvent {
  final String userId;
  
  GetCurrentRideEvent({
    required this.userId,
  });
  
  @override
  List<Object?> get props => [userId];
}

class GetAllRidesByUserIdEvent extends RideEvent {
  final String userId;
  
  GetAllRidesByUserIdEvent({
    required this.userId,
  });
  
  @override
  List<Object?> get props => [userId];
}

class GetRecentRidesByUserIdEvent extends RideEvent {
  final String userId;
  final int limit;
  
  GetRecentRidesByUserIdEvent({
    required this.userId,
    this.limit = 10,
  });
  
  @override
  List<Object?> get props => [userId, limit];
}

class UploadRideEvent extends RideEvent {
  final RideEntity rideEntity;
  
  UploadRideEvent({
    required this.rideEntity,
  });
  
  @override
  List<Object?> get props => [rideEntity];
}

class DiscardRideEvent extends RideEvent {
  final String userId;
  
  DiscardRideEvent({
    required this.userId,
  });
  
  @override
  List<Object?> get props => [userId];
}

class UpdateRideFieldsEvent extends RideEvent {
  final String userId;
  final Map<String, dynamic> fields;
  
  UpdateRideFieldsEvent({
    required this.userId,
    required this.fields,
  });
  
  @override
  List<Object?> get props => [userId, fields];
}

class GetRideMemoriesByUserIdEvent extends RideEvent {
  final String userId;
  
  GetRideMemoriesByUserIdEvent({
    required this.userId,
  });
  
  @override
  List<Object?> get props => [userId];
}

class GetRecentRideMemoriesByUserIdEvent extends RideEvent {
  final String userId;
  final int limit;
  
  GetRecentRideMemoriesByUserIdEvent({
    required this.userId,
    this.limit = 10,
  });
  
  @override
  List<Object?> get props => [userId, limit];
}