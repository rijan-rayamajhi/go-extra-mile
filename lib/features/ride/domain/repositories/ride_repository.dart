import '../entities/ride_entity.dart';
import '../entities/ride_memory_entity.dart';

abstract class RideRepository {
  Future<RideEntity> startRide(
    RideEntity rideEntity,
  );
  
  Future<RideEntity?> getCurrentRide(String userId);
  
  Future<void> uploadRide(RideEntity rideEntity);
  
  /// 🔹 Get all rides for a specific user
  Future<List<RideEntity>> getAllRidesByUserId(String userId);
  
  /// 🔹 Get recent rides for a specific user with optional limit
  Future<List<RideEntity>> getRecentRidesByUserId(String userId, {int limit = 10});
  
  /// 🔹 Discard/delete a ride
  Future<void> discardRide(String userId);

  /// 🔹 Stream current ride data for real-time updates
  Stream<RideEntity?> watchCurrentRide(String userId);

  /// 🔹 Update specific fields of the current ride
  Future<void> updateRideFields(String userId, Map<String, dynamic> fields);

  /// 🔹 Get all ride memories for a specific user
  Future<List<RideMemoryEntity>> getRideMemoriesByUserId(String userId);

  /// 🔹 Get recent ride memories for a specific user with optional limit
  Future<List<RideMemoryEntity>> getRecentRideMemoriesByUserId(String userId, {int limit = 10});
} 