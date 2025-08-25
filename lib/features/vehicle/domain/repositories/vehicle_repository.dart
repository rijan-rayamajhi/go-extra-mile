import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';

abstract class VehicleRepository {
  /// Get all vehicles of a user
  Future<Either<Exception, List<VehicleEntity>>> getUserVehicles(String userId);

  /// Add a new vehicle
  Future<Either<Exception, void>> addVehicle(VehicleEntity vehicle, String userId);
}