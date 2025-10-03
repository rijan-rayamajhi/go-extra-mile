import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/repositories/ride_repository.dart';

class UploadRide {
  final RideRepository repository;

  UploadRide(this.repository);

  Future<void> call(RideEntity ride) async {
    return await repository.uploadRide(ride);
  }
}
