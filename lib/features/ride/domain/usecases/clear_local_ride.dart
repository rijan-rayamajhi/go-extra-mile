import 'package:go_extra_mile_new/features/ride/domain/repositories/ride_repository.dart';

class ClearLocalRide {
  final RideRepository repository;

  ClearLocalRide(this.repository);

  Future<void> call(String rideId) async {
    return await repository.clearLocalRide(rideId);
  }
}
