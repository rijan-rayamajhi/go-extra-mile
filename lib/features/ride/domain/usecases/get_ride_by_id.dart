import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/repositories/ride_repository.dart';

class GetRideById {
  final RideRepository repository;

  GetRideById(this.repository);

  Future<RideEntity?> call(String id) async {
    return await repository.getRideById(id);
  }
}
