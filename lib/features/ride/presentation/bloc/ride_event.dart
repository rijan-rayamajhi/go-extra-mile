import 'package:equatable/equatable.dart';

import '../../domain/entities/ride_entity.dart';

abstract class RideEvent extends Equatable {
  @override 
  List<Object?> get props => [];
}


// Fetches all rides for a specific user - used in MyRideScreen to display complete ride history
class GetAllRidesByUserIdEvent extends RideEvent {
  final String userId;
  
  GetAllRidesByUserIdEvent({
    required this.userId,
  });
  
  @override
  List<Object?> get props => [userId];
}

// Fetches recent rides for a user with optional limit - used for displaying recent ride history on home screen
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

// Saves a completed ride to the database - used in SaveRideScreen to persist ride data
class UploadRideEvent extends RideEvent {
  final RideEntity rideEntity;
  
  UploadRideEvent({
    required this.rideEntity,
  });
  
  @override
  List<Object?> get props => [rideEntity];
}

// Saves a ride locally for offline access - used for caching ride data before upload
class SaveRideLocallyEvent extends RideEvent {
  final RideEntity rideEntity;
  
  SaveRideLocallyEvent({
    required this.rideEntity,
  });
  
  @override
  List<Object?> get props => [rideEntity];
}

// Retrieves rides stored locally for a specific user - used for offline ride history
class GetRideLocallyEvent extends RideEvent {
  final String userId;
  
  GetRideLocallyEvent({
    required this.userId,
  });
  
  @override
  List<Object?> get props => [userId];
}