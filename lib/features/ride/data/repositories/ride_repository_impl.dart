import 'package:go_extra_mile_new/core/service/internet_connection_service.dart';
import 'package:go_extra_mile_new/features/ride/data/datasource/ride_firebase_datasource.dart';
import 'package:go_extra_mile_new/features/ride/data/datasource/ride_hive_datasource.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/repositories/ride_repository.dart';

class RideRepositoryImpl implements RideRepository {
  final RideFirebaseDatasource remoteDataSource;
  final RideHiveDatasource localDataSource;
  final InternetConnectionService _connectionService =
      InternetConnectionService();

  RideRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<RideEntity>> getAllFirebaseRides() async {
    return remoteDataSource.getAllFirebaseRides();
  }

  @override
  Future<List<RideEntity>> getAllHiveRides() async {
    return localDataSource.getAllHiveRides();
  }

  @override
  Future<void> uploadRide(RideEntity ride) async {
    // Save to Firebase if online
    if (await _connectionService.checkConnection()) {
      await remoteDataSource.uploadRide(ride);
    } else {
      await localDataSource.uploadRide(ride);
    }
  }

  @override
  Future<RideEntity?> getRecentRide() async {
    final localRecent = await localDataSource.getRecentRide();
    final remoteRecent = await remoteDataSource.getRecentRide();
    if (localRecent == null) return remoteRecent;
    if (remoteRecent == null) return localRecent;
    // Compare startedAt to get the most recent ride
    final localTime =
        localRecent.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final remoteTime =
        remoteRecent.startedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

    return remoteTime.isAfter(localTime) ? remoteRecent : localRecent;
  }

  @override
  Future<RideEntity?> getRideById(String id) async {
    return await remoteDataSource.getRideById(id);
  }

  @override
  Future<void> clearLocalRide(String rideId) async {
    await localDataSource.clearRide(rideId);
  }
}
