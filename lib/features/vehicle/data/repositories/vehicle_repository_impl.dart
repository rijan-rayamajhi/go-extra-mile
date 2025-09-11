import 'dart:io';

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

  @override
  Future<Either<Exception, String>> uploadVehicleImage(String vehicleId, String userId, File imageFile, String fieldName) async {
    try {
      final imageUrl = await _firestoreDatasource.uploadVehicleImage(vehicleId, userId, imageFile, fieldName);
      return Right(imageUrl);
    } catch (e) {
      return Left(Exception('Failed to upload vehicle image: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> deleteVehicleImage(String vehicleId, String userId, String fieldName, String imageUrl) async {
    try {
      await _firestoreDatasource.deleteVehicleImage(vehicleId, userId, fieldName, imageUrl);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to delete vehicle image: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> verifyVehicle(String vehicleId, String userId) async {
    try {
      await _firestoreDatasource.verifyVehicle(vehicleId, userId);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Failed to verify vehicle: $e'));
    }
  }
}
