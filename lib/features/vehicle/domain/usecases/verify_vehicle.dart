import 'package:dartz/dartz.dart';
import '../repositories/vehicle_repository.dart';

class VerifyVehicle {
  final VehicleRepository repository;

  VerifyVehicle(this.repository);

  Future<Either<Exception, void>> call(String vehicleId, String userId) async {
    return await repository.verifyVehicle(vehicleId, userId);
  }
}
