
import '../../domain/repositories/ride_repository.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/ride_memory_entity.dart';
import '../datasources/ride_local_datasource.dart';
import '../models/ride_model.dart';
import '../datasources/ride_firestore_datasource.dart';

class RideRepositoryImpl implements RideRepository {
  final RideLocalDatasource _localDatasource;
  final RideFirestoreDataSource _firestoreDatasource;

  RideRepositoryImpl(this._localDatasource, this._firestoreDatasource);

  @override
  Future<RideEntity> startRide(RideEntity rideEntity) async {
    try {
      // Convert entity to model for local storage
      final rideModel = RideModel(
        id: rideEntity.id,
        userId: rideEntity.userId,
        vehicleId: rideEntity.vehicleId,
        status: rideEntity.status,
        startedAt: rideEntity.startedAt,
        startCoordinates: rideEntity.startCoordinates,
      );

      // Save ride to local storage
      await _localDatasource.saveRide(rideModel);
      
      return rideModel;
    } catch (e) {
      throw Exception('Failed to start ride: $e');
    }
  }

  @override
  Future<RideEntity?> getCurrentRide(String userId) async {
    try {
      final rideModel = await _localDatasource.getRide(userId);
      return rideModel;
    } catch (e) {
      throw Exception('Failed to get current ride: $e');
    }
  }

  @override
  Future<void> uploadRide(RideEntity rideEntity) async {
    try {

      print('Ride Entity before conversion: $rideEntity');
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
      );

      print('Ride Entity Model  conversion: $rideModel');
      // Upload to Firestore using the injected datasource
      await _firestoreDatasource.uploadRide(rideModel);
      
      // // Clear local storage ride data after successful upload
      // await _localDatasource.clearRide(rideEntity.userId);
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
  Future<void> discardRide(String userId) async {
    try {
      // Clear local ride data
      await _localDatasource.clearRide(userId);
    } catch (e) {
      throw Exception('Failed to discard ride: $e');
    }
  }

  @override
  Stream<RideEntity?> watchCurrentRide(String userId) {
    try {
      return _localDatasource.watchCurrentRide(userId);
    } catch (e) {
      throw Exception('Failed to watch current ride: $e');
    }
  }

  @override
  Future<void> updateRideFields(String userId, Map<String, dynamic> fields) async {
    try {
      await _localDatasource.updateRideFields(userId, fields);
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to update ride fields: $e');
    }
  }

  @override
  Future<List<RideMemoryEntity>> getRideMemoriesByUserId(String userId) async {
    try {
      final rideMemories = await _firestoreDatasource.getRideMemoriesByUserId(userId);
      return rideMemories;
    } catch (e) {
      throw Exception('Failed to get ride memories for user $userId: $e');
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
} 