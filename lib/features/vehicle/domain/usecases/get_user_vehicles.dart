import 'package:dartz/dartz.dart';
import '../repositories/vehicle_repository.dart';
import '../entities/vehicle_entiry.dart';

class GetUserVehicles {
  final VehicleRepository repository;

  GetUserVehicles(this.repository);

  Future<Either<Exception, List<VehicleEntity>>> call(String userId) async {
    return await repository.getUserVehicles(userId);
  }
}
