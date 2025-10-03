import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_brand_entity.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';

abstract class VehicleRepository {
  /// Get all vehicle brands
  Future<Either<Exception, List<VehicleBrandEntity>>> getAllVehicleBrands();

  /// Get all vehicles of a user
  Future<Either<Exception, List<VehicleEntity>>> getUserVehicles(String userId);

  /// Add a new vehicle
  Future<Either<Exception, void>> addVehicle(
    VehicleEntity vehicle,
    String userId,
  );

  /// Delete a vehicle
  Future<Either<Exception, void>> deleteVehicle(
    String vehicleId,
    String userId,
  );

  //upload image and doc
  Future<Either<Exception, String>> uploadVehicleImage(
    String vehicleId,
    String userId,
    File imageFile,
    String fieldName,
  );

  //delete image and doc
  Future<Either<Exception, void>> deleteVehicleImage(
    String vehicleId,
    String userId,
    String fieldName,
    String imageUrl,
  );

  //verify and earn
  Future<Either<Exception, void>> verifyVehicle(
    String vehicleId,
    String userId,
  );
}
