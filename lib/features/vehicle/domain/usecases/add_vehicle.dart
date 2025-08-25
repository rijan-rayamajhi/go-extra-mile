import 'package:dartz/dartz.dart';
import '../repositories/vehicle_repository.dart';
import '../entities/vehicle_entiry.dart';

class AddVehicle {
  final VehicleRepository repository;

  AddVehicle(this.repository);

  Future<Either<Exception, void>> call(VehicleEntity vehicle, String userId) async {
    return await repository.addVehicle(vehicle, userId);
  }
}
