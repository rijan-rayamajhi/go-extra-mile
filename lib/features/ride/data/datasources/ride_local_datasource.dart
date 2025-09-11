
import 'package:hive/hive.dart';
import '../../domain/entities/ride_entity.dart';
import '../models/ride_model.dart';
import '../../../../core/error/exceptions.dart';

class RideLocalDatasource {
  static const String _ridesBoxName = 'rides';
  static const String _userRidesBoxName = 'user_rides';
  Box<RideModel>? _ridesBox;
  Box<List<String>>? _userRidesBox;

  /// 🔹 Initialize Hive boxes for rides
  Future<void> init() async {
    _ridesBox = await Hive.openBox<RideModel>(_ridesBoxName);
    _userRidesBox = await Hive.openBox<List<String>>(_userRidesBoxName);
  }

  /// 🔹 Get cache key for a specific user
  String _getUserRidesKey(String userId) => 'user_rides_$userId';

  /// 🔹 Get cache key for a specific ride
  String _getRideKey(String rideId) => 'ride_$rideId';

  /// 🔹 Save ride locally using Hive
  Future<void> saveRide(RideEntity rideEntity) async {
    try {
      if (_ridesBox == null || _userRidesBox == null) await init();
      
      // Convert entity to model for Hive storage
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

      // Store ride with ride ID as key
      await _ridesBox!.put(_getRideKey(rideEntity.id), rideModel);
      
      // Also store ride ID in user's ride list for easy retrieval
      final userRidesKey = _getUserRidesKey(rideEntity.userId);
      final existingRides = _userRidesBox!.get(userRidesKey, defaultValue: <String>[]) ?? [];
      
      if (!existingRides.contains(rideEntity.id)) {
        existingRides.add(rideEntity.id);
        await _userRidesBox!.put(userRidesKey, existingRides);
      }
    } catch (e) {
      throw DataException('Failed to save ride locally: $e');
    }
  }

  /// 🔹 Get ride locally by ride ID
  Future<RideEntity?> getRide(String rideId) async {
    try {
      if (_ridesBox == null) await init();
      
      final rideModel = _ridesBox!.get(_getRideKey(rideId));
      return rideModel;
    } catch (e) {
      throw DataException('Failed to get ride locally: $e');
    }
  }

  /// 🔹 Get all rides for a specific user
  Future<List<RideEntity>> getUserRides(String userId) async {
    try {
      if (_ridesBox == null || _userRidesBox == null) await init();
      
      final userRidesKey = _getUserRidesKey(userId);
      final rideIds = _userRidesBox!.get(userRidesKey, defaultValue: <String>[]) ?? [];
      
      final rides = <RideEntity>[];
      for (final rideId in rideIds) {
        final ride = _ridesBox!.get(_getRideKey(rideId));
        if (ride != null) {
          rides.add(ride);
        }
      }
      
      // Sort by startedAt descending (most recent first)
      rides.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      
      return rides;
    } catch (e) {
      throw DataException('Failed to get user rides locally: $e');
    }
  }

  /// 🔹 Clear all rides for a specific user
  Future<void> clearRide(String userId) async {
    try {
      if (_ridesBox == null || _userRidesBox == null) await init();
      
      final userRidesKey = _getUserRidesKey(userId);
      final rideIds = _userRidesBox!.get(userRidesKey, defaultValue: <String>[]) ?? [];
      
      // Remove individual ride entries
      for (final rideId in rideIds) {
        await _ridesBox!.delete(_getRideKey(rideId));
      }
      
      // Remove user's ride list
      await _userRidesBox!.delete(userRidesKey);
    } catch (e) {
      throw DataException('Failed to clear rides for user: $e');
    }
  }

  /// 🔹 Clear a specific ride
  Future<void> clearSpecificRide(String rideId) async {
    try {
      if (_ridesBox == null || _userRidesBox == null) await init();
      
      // Get the ride to find the user ID
      final ride = _ridesBox!.get(_getRideKey(rideId));
      if (ride != null) {
        // Remove from user's ride list
        final userRidesKey = _getUserRidesKey(ride.userId);
        final rideIds = _userRidesBox!.get(userRidesKey, defaultValue: <String>[]) ?? [];
        rideIds.remove(rideId);
        await _userRidesBox!.put(userRidesKey, rideIds);
      }
      
      // Remove the ride entry
      await _ridesBox!.delete(_getRideKey(rideId));
    } catch (e) {
      throw DataException('Failed to clear specific ride: $e');
    }
  }

  /// 🔹 Clear all rides (use with caution)
  Future<void> clearAllRides() async {
    try {
      if (_ridesBox == null || _userRidesBox == null) await init();
      await _ridesBox!.clear();
      await _userRidesBox!.clear();
    } catch (e) {
      throw DataException('Failed to clear all rides: $e');
    }
  }

  /// 🔹 Close the Hive boxes
  Future<void> close() async {
    await _ridesBox?.close();
    await _userRidesBox?.close();
  }
}
