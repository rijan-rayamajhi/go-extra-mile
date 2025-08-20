import 'package:equatable/equatable.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/ride_memory_entity.dart';

abstract class RideState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RideInitial extends RideState {}

class RideLoading extends RideState {}

class RideStarted extends RideState {
  final RideEntity ride;
  RideStarted(this.ride);
  
  @override 
  List<Object?> get props => [ride];
}

class CurrentRideLoaded extends RideState {
  final RideEntity? ride;
  CurrentRideLoaded(this.ride);
  
  @override 
  List<Object?> get props => [ride];
}

class AllRidesLoaded extends RideState {
  final List<RideEntity> rides;
  AllRidesLoaded(this.rides);
  
  @override 
  List<Object?> get props => [rides];
}

class RecentRidesLoaded extends RideState {
  final List<RideEntity> rides;
  final int limit;
  RecentRidesLoaded(this.rides, this.limit);
  
  @override 
  List<Object?> get props => [rides, limit];
}

class RideUploaded extends RideState {}

class RideDiscarded extends RideState {}

class RideFieldsUpdated extends RideState {
  final String userId;
  final Map<String, dynamic> updatedFields;
  
  RideFieldsUpdated({
    required this.userId,
    required this.updatedFields,
  });
  
  @override
  List<Object?> get props => [userId, updatedFields];
}

class RideMemoriesLoaded extends RideState {
  final List<RideMemoryEntity> memories;
  RideMemoriesLoaded(this.memories);
  
  @override 
  List<Object?> get props => [memories];
}

class RecentRideMemoriesLoaded extends RideState {
  final List<RideMemoryEntity> memories;
  final int limit;
  RecentRideMemoriesLoaded(this.memories, this.limit);
  
  @override 
  List<Object?> get props => [memories, limit];
}

class RideFailure extends RideState {
  final String message;
  RideFailure(this.message);
  
  @override 
  List<Object?> get props => [message];
} 