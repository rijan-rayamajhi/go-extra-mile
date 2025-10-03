import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/repositories/ride_repository.dart';

class GetAllFirebaseRides {
  final RideRepository repository;

  GetAllFirebaseRides(this.repository);

  Future<List<RideEntity>> call() async {
    return await repository.getAllFirebaseRides();
  }
}
