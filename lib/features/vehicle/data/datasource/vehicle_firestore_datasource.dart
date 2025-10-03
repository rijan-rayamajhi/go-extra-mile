import 'dart:io';

import 'package:go_extra_mile_new/core/service/firebase_storage_service.dart';

import '../model/vehicle_model.dart';
import '../model/vehicle_brand_model.dart';
import '../../../../core/error/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorageService _storage = FirebaseStorageService();

  /// 🔹 Get vehicles subcollection reference for a specific user
  CollectionReference<Map<String, dynamic>> _getUserVehiclesCollection(
    String userId,
  ) => _firestore.collection('users').doc(userId).collection('vehicles');

  /// 🔹 Get vehicle brands collection reference
  CollectionReference<Map<String, dynamic>> _getVehicleBrandsCollection() =>
      _firestore.collection('vehicleBrands');

  /// 🔹 Get all vehicle brands
  Future<List<VehicleBrandModel>> getAllVehicleBrands() async {
    try {
      final querySnapshot = await _getVehicleBrandsCollection()
          .orderBy('name', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => VehicleBrandModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get vehicle brands: $e');
    }
  }

  /// 🔹 Add a new vehicle to user's vehicles subcollection
  Future<void> addVehicle(VehicleModel vehicle, String userId) async {
    try {
      // Convert vehicle model to Firestore document
      final vehicleData = vehicle.toDocument();

      // Add document ID if provided, otherwise let Firestore generate one
      if (vehicle.id.isNotEmpty) {
        await _getUserVehiclesCollection(
          userId,
        ).doc(vehicle.id).set(vehicleData);
      } else {
        await _getUserVehiclesCollection(userId).add(vehicleData);
      }
    } catch (e) {
      throw DatabaseException('Failed to add vehicle: $e');
    }
  }

  /// 🔹 Get all vehicles for a specific user
  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    try {
      final querySnapshot = await _getUserVehiclesCollection(userId)
          .orderBy(
            'vehicleBrandName',
            descending: false,
          ) // Alphabetical order by brand
          .get();

      return querySnapshot.docs
          .map((doc) => VehicleModel.fromDocument(doc))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get vehicles for user $userId: $e');
    }
  }

  /// 🔹 Delete a vehicle from user's vehicles subcollection
  Future<void> deleteVehicle(String vehicleId, String userId) async {
    try {
      await _getUserVehiclesCollection(userId).doc(vehicleId).delete();
    } catch (e) {
      throw DatabaseException('Failed to delete vehicle: $e');
    }
  }

  //upload image and doc
  Future<String> uploadVehicleImage(
    String vehicleId,
    String userId,
    File imageFile,
    String fieldName,
  ) async {
    try {
      //upload to firebase storage
      final url = await _storage.uploadFile(
        file: imageFile,
        path: 'vehicles/$userId/$vehicleId/$fieldName',
      );

      //there is two types of image update to vechile collection either adding to list or replacing it its depends on fieldName
      if (fieldName == 'vehicleSlideImages') {
        await _getUserVehiclesCollection(userId).doc(vehicleId).update({
          fieldName: FieldValue.arrayUnion([url]),
        });
      } else {
        await _getUserVehiclesCollection(
          userId,
        ).doc(vehicleId).update({fieldName: url});
      }

      return url;
    } catch (e) {
      throw DatabaseException('Failed to upload vehicle image: $e');
    }
  }

  Future<void> deleteVehicleImage(
    String vehicleId,
    String userId,
    String fieldName,
    String imageUrl,
  ) async {
    try {
      // 2️⃣ Update Firestore document
      final docRef = _getUserVehiclesCollection(userId).doc(vehicleId);
      if (fieldName == 'vehicleSlideImages') {
        // remove from array
        await docRef.update({
          fieldName: FieldValue.arrayRemove([imageUrl]),
        });
      } else {
        // single value field
        await docRef.update({fieldName: FieldValue.delete()});
        // or you can set it to null: {fieldName: null}
      }
    } catch (e) {
      throw DatabaseException('Failed to delete vehicle image: $e');
    }
  }

  /// 🔹 Verify a vehicle for earning rewards
  Future<void> verifyVehicle(String vehicleId, String userId) async {
    try {
      final docRef = _getUserVehiclesCollection(userId).doc(vehicleId);

      // Update verification status to pending
      await docRef.update({
        'verificationStatus': 'pending',
        'verificationSubmittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DatabaseException('Failed to verify vehicle: $e');
    }
  }

  /// 🔹 Get total count of vehicles with verification status "notVerified"
  Future<int> getTotalNotVerifiedVehicles(String userId) async {
    try {
      // For each user, query their vehicles subcollection
      final vehiclesSnapshot = await _getUserVehiclesCollection(
        userId,
      ).where('verificationStatus', isEqualTo: 'notVerified').get();

      return vehiclesSnapshot.docs.length;
    } catch (e) {
      throw DatabaseException('Failed to get total not verified vehicles: $e');
    }
  }
}
