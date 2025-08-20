import '../models/ride_model.dart';
import '../models/ride_memory_model.dart';
import '../../../../core/error/exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideFirestoreDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 🔹 Get rides subcollection reference for a specific user
  CollectionReference<Map<String, dynamic>> _getUserRidesCollection(String userId) => 
      _firestore.collection('users').doc(userId).collection('rides');

  /// 🔹 Upload ride to user's rides subcollection
  Future<void> uploadRide(RideModel ride) async {
    try {
      // Convert ride model to Firestore document
      final rideData = ride.toFirestore();
      
      // Add document ID if provided, otherwise let Firestore generate one
      if (ride.id.isNotEmpty) {
        await _getUserRidesCollection(ride.userId).doc(ride.id).set(rideData);
      } else {
        await _getUserRidesCollection(ride.userId).add(rideData);
      }
    } catch (e) {
      throw DatabaseException('Failed to upload ride: $e');
    }
  }
  
  /// 🔹 Get all rides for a specific user
  Future<List<RideModel>> getAllRidesByUserId(String userId) async {
    try {
      final querySnapshot = await _getUserRidesCollection(userId)
          .orderBy('startedAt', descending: true) // Most recent rides first
          .get();
      
      return querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get rides for user $userId: $e');
    }
  }
  
  /// 🔹 Get recent rides for a specific user with optional limit
  Future<List<RideModel>> getRecentRidesByUserId(String userId, {int limit = 10}) async {
    try {
      final querySnapshot = await _getUserRidesCollection(userId)
          .orderBy('startedAt', descending: true) // Most recent rides first
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => RideModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw DatabaseException('Failed to get recent rides for user $userId: $e');
    }
  }

  /// 🔹 Get all ride memories for a specific user
  Future<List<RideMemoryModel>> getRideMemoriesByUserId(String userId) async {
    try {
      final querySnapshot = await _getUserRidesCollection(userId)
          .where('rideMemories', isGreaterThan: []) // Only rides with memories
          .orderBy('startedAt', descending: true) // Most recent rides first
          .get();
      
      final allMemories = <RideMemoryModel>[];
      
      for (final doc in querySnapshot.docs) {
        final rideData = doc.data();
        final rideMemories = rideData['rideMemories'] as List<dynamic>?;
        
        if (rideMemories != null && rideMemories.isNotEmpty) {
          for (final memoryData in rideMemories) {
            if (memoryData is Map<String, dynamic>) {
              // Add ride context to memory data
              final memoryWithRideContext = {
                ...memoryData,
                'rideId': doc.id,
                'rideStartedAt': rideData['startedAt'],
              };
              
              try {
                final memory = RideMemoryModel.fromFirestore(memoryWithRideContext);
                allMemories.add(memory);
              } catch (e) {
                // Skip invalid memory data
                print('Skipping invalid memory data: $e');
              }
            }
          }
        }
      }
      
      return allMemories;
    } catch (e) {
      throw DatabaseException('Failed to get ride memories for user $userId: $e');
    }
  }

  /// 🔹 Get recent ride memories for a specific user with optional limit
  Future<List<RideMemoryModel>> getRecentRideMemoriesByUserId(String userId, {int limit = 10}) async {
    try {
      final allMemories = await getRideMemoriesByUserId(userId);
      
      // Sort by capture time and limit results
      allMemories.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
      
      return allMemories.take(limit).toList();
    } catch (e) {
      throw DatabaseException('Failed to get recent ride memories for user $userId: $e');
    }
  }
} 