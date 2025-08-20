import '../repositories/ride_repository.dart';
import '../entities/ride_entity.dart';

class GetRecentRidesByUserId {
  final RideRepository repository;
  GetRecentRidesByUserId(this.repository);

  Future<List<RideEntity>> call(String userId, {int limit = 10}) async {
    return await repository.getRecentRidesByUserId(userId, limit: limit);
  }
}
