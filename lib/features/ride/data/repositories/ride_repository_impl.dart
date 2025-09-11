
import '../../domain/repositories/ride_repository.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/ride_memory_entity.dart';
import '../models/ride_model.dart';
import '../datasources/ride_firestore_datasource.dart';
import '../datasources/ride_local_datasource.dart';

class RideRepositoryImpl implements RideRepository {
  final RideFirestoreDataSource _firestoreDatasource;
  final RideLocalDatasource _localDatasource;

  RideRepositoryImpl(this._firestoreDatasource, this._localDatasource);

  @override
  Future<void> uploadRide(RideEntity rideEntity) async {
    try {

      // Convert entity to model for Firestore upload
      final rideModel = RideModel(
        id: rideEntity.id,
        userId: rideEntity.userId,
        vehicleId: rideEntity.vehicleId,
        status: rideEntity.status,
        startedAt: rideEntity.startedAt,
        startCoordinates: rideEntity.startCoordinates,
        endCoordinates: rideEntity.endCoordinates,
        endedAt: rideEntity.endedAt,
        totalDistance: rideEntity.totalDistance,
        totalTime: rideEntity.totalTime,
        totalGEMCoins: rideEntity.totalGEMCoins,
        rideMemories: rideEntity.rideMemories,
        rideTitle: rideEntity.rideTitle,
        rideDescription: rideEntity.rideDescription,
        topSpeed: rideEntity.topSpeed,
        averageSpeed: rideEntity.averageSpeed,
        routePoints: rideEntity.routePoints,
        isPublic: rideEntity.isPublic,
      );

      // Upload to Firestore using the injected datasource
      await _firestoreDatasource.uploadRide(rideModel);
      
      // Clear local storage ride data after successful upload
      await _localDatasource.clearSpecificRide(rideEntity.id);
    } catch (e) {
      throw Exception('Failed to upload ride: $e');
    }
  }
  
  @override
  Future<List<RideEntity>> getAllRidesByUserId(String userId) async {
    try {
      final rides = await _firestoreDatasource.getAllRidesByUserId(userId);
      return rides;
    } catch (e) {
      throw Exception('Failed to get rides for user $userId: $e');
    }
  }
  
  @override
  Future<List<RideEntity>> getRecentRidesByUserId(String userId, {int limit = 1}) async {
    try {
      final rides = await _firestoreDatasource.getRecentRidesByUserId(userId, limit: limit);
      return rides;
    } catch (e) {
      throw Exception('Failed to get recent rides for user $userId: $e');
    }
  }
  


  @override
  Future<List<RideMemoryEntity>> getRecentRideMemoriesByUserId(String userId, {int limit = 10}) async {
    try {
      final rideMemories = await _firestoreDatasource.getRecentRideMemoriesByUserId(userId, limit: limit);
      return rideMemories;
    } catch (e) {
      throw Exception('Failed to get recent ride memories for user $userId: $e');
    }
  }
 
  @override
  Future<void> saveRideLocally(RideEntity rideEntity) async {
    try {
      await _localDatasource.saveRide(rideEntity);
    } catch (e) {
      throw Exception('Failed to save ride locally: $e');
    }
  }


  @override
  Future<List<RideEntity>> getRideLocally(String userId) async {
    try {
      return await _localDatasource.getUserRides(userId);
    } catch (e) {
      throw Exception('Failed to get rides locally: $e');
    }
  }

} 