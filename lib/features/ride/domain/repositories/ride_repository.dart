import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

abstract class RideRepository {
  /// Fetches all rides
  Future<List<RideEntity>> getAllFirebaseRides();
  Future<List<RideEntity>> getAllHiveRides();

  Future<RideEntity?> getRecentRide();

  /// Fetches a single ride by its ID
  Future<RideEntity?> getRideById(String id);

  /// Uploads a new ride
  Future<void> uploadRide(RideEntity ride);
}
