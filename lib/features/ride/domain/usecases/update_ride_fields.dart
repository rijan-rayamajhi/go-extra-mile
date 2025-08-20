import '../repositories/ride_repository.dart';

class UpdateRideFields {
  final RideRepository repository;
  UpdateRideFields(this.repository);

  Future<void> call(String userId, Map<String, dynamic> fields) async {
    return await repository.updateRideFields(userId, fields);
  }
}
