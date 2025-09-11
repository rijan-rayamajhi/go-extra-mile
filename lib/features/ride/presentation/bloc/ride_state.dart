import 'package:equatable/equatable.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/ride_memory_entity.dart';

abstract class RideState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RideInitial extends RideState {}

class RideLoading extends RideState {}


class AllRidesLoaded extends RideState {
  final List<RideEntity> rides;
  final List<RideEntity> localRides;
  AllRidesLoaded(this.rides, {this.localRides = const []});
  
  @override 
  List<Object?> get props => [rides, localRides];
}

class RecentRidesLoaded extends RideState {
  final List<RideEntity> rides;
  final List<RideEntity> localRides;
  final int limit;
  RecentRidesLoaded(this.rides, this.limit, {this.localRides = const []});
  
  @override 
  List<Object?> get props => [rides, localRides, limit];
}

class RideUploaded extends RideState {}


class RideMemoriesLoaded extends RideState {
  final List<RideMemoryEntity> memories;
  RideMemoriesLoaded(this.memories);
  
  @override 
  List<Object?> get props => [memories];
}

// class RecentRideMemoriesLoaded extends RideState {
//   final List<RideMemoryEntity> memories;
//   final int limit;
//   RecentRideMemoriesLoaded(this.memories, this.limit);
  
//   @override 
//   List<Object?> get props => [memories, limit];
// }

class RideFailure extends RideState {
  final String message;
  RideFailure(this.message);
  
  @override 
  List<Object?> get props => [message];
} 