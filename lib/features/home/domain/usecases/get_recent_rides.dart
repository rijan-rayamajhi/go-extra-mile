import 'package:go_extra_mile_new/features/home/domain/home_repositories.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

class GetRecentRidesUseCase {
  final HomeRepository repository;

  GetRecentRidesUseCase(this.repository);

  Future<Map<String, List<RideEntity>>> call() async {
    return await repository.getRecentRides();
  }
}
