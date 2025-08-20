import 'package:equatable/equatable.dart';
import '../entities/ride_memory_entity.dart';
import '../repositories/ride_repository.dart';

class GetRecentRideMemoriesByUserId extends Equatable {
  final RideRepository repository;

  const GetRecentRideMemoriesByUserId(this.repository);

  Future<List<RideMemoryEntity>> call(String userId, {int limit = 10}) async {
    return await repository.getRecentRideMemoriesByUserId(userId, limit: limit);
  }

  @override
  List<Object?> get props => [repository];
}
