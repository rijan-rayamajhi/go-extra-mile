import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/repositories/ride_repository.dart';

class GetRecentRide {
  final RideRepository repository;

  GetRecentRide(this.repository);

  Future<RideEntity?> call() async {
    return await repository.getRecentRide();
  }
}
