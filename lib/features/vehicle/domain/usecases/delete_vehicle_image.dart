import 'package:dartz/dartz.dart';
import '../repositories/vehicle_repository.dart';

class DeleteVehicleImage {
  final VehicleRepository repository;

  DeleteVehicleImage(this.repository);

  Future<Either<Exception, void>> call(
    String vehicleId,
    String userId,
    String fieldName,
    String imageUrl,
  ) async {
    return await repository.deleteVehicleImage(
      vehicleId,
      userId,
      fieldName,
      imageUrl,
    );
  }
}
