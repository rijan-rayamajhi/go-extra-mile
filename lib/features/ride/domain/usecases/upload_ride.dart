import '../repositories/ride_repository.dart';
import '../entities/ride_entity.dart';

class UploadRide {
  final RideRepository repository;
  UploadRide(this.repository);

  Future<void> call(RideEntity rideEntity) async {
    return await repository.uploadRide(rideEntity);
  }
}
