import 'package:equatable/equatable.dart';
import '../entities/ride_memory_entity.dart';
import '../repositories/ride_repository.dart';

class GetRideMemoriesByUserId extends Equatable {
  final RideRepository repository;

  const GetRideMemoriesByUserId(this.repository);

  Future<List<RideMemoryEntity>> call(String userId) async {
    return await repository.getRideMemoriesByUserId(userId);
  }

  @override
  List<Object?> get props => [repository];
}
