import '../repositories/ride_repository.dart';

class DiscardRide {
  final RideRepository _rideRepository;

  DiscardRide(this._rideRepository);

  Future<void> call(String userId) async {
    await _rideRepository.discardRide(userId);
  }
}
