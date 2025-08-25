import '../model/vehicle_model.dart';
import '../../../../core/error/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 🔹 Get vehicles subcollection reference for a specific user
  CollectionReference<Map<String, dynamic>> _getUserVehiclesCollection(String userId) => 
      _firestore.collection('users').doc(userId).collection('vehicles');

  /// 🔹 Add a new vehicle to user's vehicles subcollection
  Future<void> addVehicle(VehicleModel vehicle, String userId) async {
    try {
      // Convert vehicle model to Firestore document
      final vehicleData = vehicle.toDocument();

      // Add document ID if provided, otherwise let Firestore generate one
      if (vehicle.id.isNotEmpty) {
        await _getUserVehiclesCollection(userId).doc(vehicle.id).set(vehicleData);
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
          .orderBy('vehicleBrandName', descending: false) // Alphabetical order by brand
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
}
