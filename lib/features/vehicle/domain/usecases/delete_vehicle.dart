import 'package:dartz/dartz.dart';
import '../repositories/vehicle_repository.dart';

class DeleteVehicle {
  final VehicleRepository repository;

  DeleteVehicle(this.repository);

  Future<Either<Exception, void>> call(String vehicleId, String userId) async {
    return await repository.deleteVehicle(vehicleId, userId);
  }
}
