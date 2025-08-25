import 'package:dartz/dartz.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../../domain/entities/vehicle_entiry.dart';
import '../model/vehicle_model.dart';
import '../datasource/vehicle_firestore_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleFirestoreDataSource _firestoreDatasource;

  VehicleRepositoryImpl(this._firestoreDatasource);

  @override
  Future<Either<Exception, List<VehicleEntity>>> getUserVehicles(String userId) async {
    try {
      final vehicles = await _firestoreDatasource.getUserVehicles(userId);
      return Right(vehicles);
    } catch (e) {
      return Left(Exception('Failed to get vehicles for user $userId: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> addVehicle(VehicleEntity vehicle, String userId) async {
    try {
      // Convert entity to model for Firestore storage
      final vehicleModel = VehicleModel(
        id: vehicle.id,
        vehicleType: vehicle.vehicleType,
        vehicleBrandImage: vehicle.vehicleBrandImage,
        vehicleBrandName: vehicle.vehicleBrandName,
        vehicleModelName: vehicle.vehicleModelName,
        vehicleRegistrationNumber: vehicle.vehicleRegistrationNumber,
        vehicleTyreType: vehicle.vehicleTyreType,
        verificationStatus: vehicle.verificationStatus,
      );

      // Add vehicle to Firestore
      await _firestoreDatasource.addVehicle(vehicleModel, userId);
      
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to add vehicle: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> deleteVehicle(String vehicleId, String userId) async {
    try {
      await _firestoreDatasource.deleteVehicle(vehicleId, userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete vehicle: $e'));
    }
  }
}
