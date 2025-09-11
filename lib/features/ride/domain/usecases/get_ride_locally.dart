import '../repositories/ride_repository.dart';
import '../entities/ride_entity.dart';

class GetRideLocally {
  final RideRepository repository;
  GetRideLocally(this.repository);

  Future<List<RideEntity>> call(String userId) async {
    return await repository.getRideLocally(userId);
  }
}
