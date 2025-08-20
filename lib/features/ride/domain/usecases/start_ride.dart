import '../repositories/ride_repository.dart';
import '../entities/ride_entity.dart';

class StartRide {
  final RideRepository repository;
  StartRide(this.repository);

  Future<RideEntity> call(RideEntity rideEntity) async {
    return await repository.startRide(rideEntity);
  }
}
