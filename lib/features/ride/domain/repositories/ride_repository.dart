import '../entities/ride_entity.dart';
import '../entities/ride_memory_entity.dart';

abstract class RideRepository {
  Future<void> uploadRide(RideEntity rideEntity);
  
  /// 🔹 Get all rides for a specific user
  Future<List<RideEntity>> getAllRidesByUserId(String userId);
  
  /// 🔹 Get recent rides for a specific user with optional limit
  Future<List<RideEntity>> getRecentRidesByUserId(String userId, {int limit = 1});
  

  /// 🔹 Get recent ride memories for a specific user with optional limit
  Future<List<RideMemoryEntity>> getRecentRideMemoriesByUserId(String userId, {int limit = 10});


  ///save ride locally 
  Future<void> saveRideLocally(RideEntity rideEntity);

  ///get rides locally for a user
  Future<List<RideEntity>> getRideLocally(String userId);


} 