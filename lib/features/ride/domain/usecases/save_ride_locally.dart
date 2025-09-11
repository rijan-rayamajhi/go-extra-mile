import '../repositories/ride_repository.dart';
import '../entities/ride_entity.dart';

class SaveRideLocally {
  final RideRepository repository;
  SaveRideLocally(this.repository);

  Future<void> call(RideEntity rideEntity) async {
    return await repository.saveRideLocally(rideEntity);
  }
}
