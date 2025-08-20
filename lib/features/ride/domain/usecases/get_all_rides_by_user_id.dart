import '../repositories/ride_repository.dart';
import '../entities/ride_entity.dart';

class GetAllRidesByUserId {
  final RideRepository repository;
  GetAllRidesByUserId(this.repository);

  Future<List<RideEntity>> call(String userId) async {
    return await repository.getAllRidesByUserId(userId);
  }
}
