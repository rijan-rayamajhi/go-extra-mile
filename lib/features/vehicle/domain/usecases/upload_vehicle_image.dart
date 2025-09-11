import 'dart:io';

import 'package:dartz/dartz.dart';
import '../repositories/vehicle_repository.dart';

class UploadVehicleImage {
  final VehicleRepository repository;

  UploadVehicleImage(this.repository);

  Future<Either<Exception, String>> call(
    String vehicleId,
    String userId,
    File imageFile,
    String fieldName,
  ) async {
    return await repository.uploadVehicleImage(
      vehicleId,
      userId,
      imageFile,
      fieldName,
    );
  }
}
