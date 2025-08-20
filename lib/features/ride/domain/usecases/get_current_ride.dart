import '../repositories/ride_repository.dart';
import '../entities/ride_entity.dart';

class GetCurrentRide {
  final RideRepository repository;
  GetCurrentRide(this.repository);

  Future<RideEntity?> call(String userId) async {
    return await repository.getCurrentRide(userId);
  }
}
