import 'package:go_extra_mile_new/features/ride/data/model/ride_model.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/ride_entity.dart';

abstract class RideHiveDatasource {
  Future<List<RideEntity>> getAllHiveRides();

  Future<RideEntity?> getRecentRide();

  /// Fetches a single ride by its ID
  Future<RideEntity?> getRideById(String id);

  /// Uploads a new ride
  Future<void> uploadRide(RideEntity ride);

  /// Clears a specific ride from local storage
  Future<void> clearRide(String rideId);
}

class RideHiveDatasourceImpl implements RideHiveDatasource {
  final Box _box = Hive.box('rides');

  @override
  Future<void> uploadRide(RideEntity ride) async {
    final rideModel = RideModel.fromEntity(ride);

    if (rideModel.id != null && rideModel.id!.isNotEmpty) {
      await _box.put(rideModel.id, rideModel.toJson());
    } else {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final rideWithId = rideModel.copyWith(id: newId);
      await _box.put(newId, rideWithId.toJson());
    }
  }

  @override
  Future<List<RideEntity>> getAllHiveRides() async {
    final rides = _box.values
        .map((e) => RideModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return rides;
  }

  @override
  Future<RideEntity?> getRideById(String id) async {
    final data = _box.get(id);
    if (data == null) return null;
    return RideModel.fromJson(Map<String, dynamic>.from(data));
  }

  @override
  Future<RideEntity?> getRecentRide() async {
    try {
      if (_box.isEmpty) return null;

      // Convert all stored rides to RideModel
      final rides = _box.values
          .map((e) => RideModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      // Sort rides by startedAt descending
      rides.sort((a, b) {
        final aTime = a.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      return rides.first;
    } catch (e) {
      // Optionally log the error
      return null;
    }
  }

  @override
  Future<void> clearRide(String rideId) async {
    await _box.delete(rideId);
  }
}
