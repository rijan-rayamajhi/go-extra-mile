import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/core/service/firebase_storage_service.dart';
import 'package:go_extra_mile_new/features/ride/data/model/ride_model.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import '../../domain/entities/ride_entity.dart';

abstract class RideFirebaseDatasource {
  /// Fetches all rides
  Future<List<RideEntity>> getAllFirebaseRides();

  Future<RideEntity?> getRecentRide();

  /// Fetches a single ride by its ID
  Future<RideEntity?> getRideById(String id);

  /// Uploads a new ride
  Future<void> uploadRide(RideEntity ride);
}

class RideFirebaseDatasourceImpl implements RideFirebaseDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  CollectionReference<Map<String, dynamic>> _userRidesCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'NO_USER',
        message: 'No authenticated user found.',
      );
    }
    return _firestore.collection('users').doc(user.uid).collection('rides');
  }

  @override
  Future<List<RideEntity>> getAllFirebaseRides() async {
    final snapshot = await _userRidesCollection()
        .orderBy('startedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => RideModel.fromFirestore(doc)).toList();
  }

  @override
  Future<RideEntity?> getRideById(String id) async {
    final doc = await _userRidesCollection().doc(id).get();
    if (!doc.exists) return null;
    return RideModel.fromFirestore(doc);
  }

  @override
  Future<void> uploadRide(RideEntity ride) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'NO_USER',
        message: 'No authenticated user found.',
      );
    }

    // Upload images and get updated ride with Firebase URLs
    final rideWithUrls = await _uploadRideImages(ride, user.uid);
    
    final rideModel = RideModel.fromEntity(rideWithUrls);
    final ridesCollection = _userRidesCollection();

    if (rideModel.id != null && rideModel.id!.isNotEmpty) {
      await ridesCollection.doc(rideModel.id).set(rideModel.toFirestore());
    } else {
      await ridesCollection.add(rideModel.toFirestore());
    }
  }

  /// Uploads all images (odometer and ride memories) to Firebase Storage
  /// and returns a new RideEntity with Firebase Storage URLs
  Future<RideEntity> _uploadRideImages(RideEntity ride, String userId) async {
    // Upload odometer images
    String? beforeOdometerUrl;
    String? afterOdometerUrl;

    if (ride.odometer?.beforeRideOdometerImage != null) {
      final beforePath = ride.odometer!.beforeRideOdometerImage!;
      if (_isLocalPath(beforePath)) {
        final file = File(beforePath);
        if (await file.exists()) {
          final storagePath = 'users/$userId/rides/${ride.id}/odometer/before_${DateTime.now().millisecondsSinceEpoch}.jpg';
          beforeOdometerUrl = await _storageService.uploadFile(
            file: file,
            path: storagePath,
          );
        }
      } else {
        beforeOdometerUrl = beforePath; // Already a URL
      }
    }

    if (ride.odometer?.afterRideOdometerImage != null) {
      final afterPath = ride.odometer!.afterRideOdometerImage!;
      if (_isLocalPath(afterPath)) {
        final file = File(afterPath);
        if (await file.exists()) {
          final storagePath = 'users/$userId/rides/${ride.id}/odometer/after_${DateTime.now().millisecondsSinceEpoch}.jpg';
          afterOdometerUrl = await _storageService.uploadFile(
            file: file,
            path: storagePath,
          );
        }
      } else {
        afterOdometerUrl = afterPath; // Already a URL
      }
    }

    // Upload ride memory images
    List<RideMemoryEntity>? updatedMemories;
    if (ride.rideMemories != null && ride.rideMemories!.isNotEmpty) {
      updatedMemories = [];
      for (var memory in ride.rideMemories!) {
        String? memoryImageUrl;
        
        if (memory.imageUrl != null) {
          final imagePath = memory.imageUrl!;
          if (_isLocalPath(imagePath)) {
            final file = File(imagePath);
            if (await file.exists()) {
              final storagePath = 'users/$userId/rides/${ride.id}/memories/${memory.id ?? DateTime.now().millisecondsSinceEpoch}.jpg';
              memoryImageUrl = await _storageService.uploadFile(
                file: file,
                path: storagePath,
              );
            }
          } else {
            memoryImageUrl = imagePath; // Already a URL
          }
        }

        updatedMemories.add(
          memory.copyWith(
            imageUrl: memoryImageUrl ?? memory.imageUrl,
          ),
        );
      }
    }

    // Create updated odometer entity with URLs
    final updatedOdometer = ride.odometer?.copyWith(
      beforeRideOdometerImage: beforeOdometerUrl ?? ride.odometer?.beforeRideOdometerImage,
      afterRideOdometerImage: afterOdometerUrl ?? ride.odometer?.afterRideOdometerImage,
    );

    // Return updated ride with Firebase URLs
    return ride.copyWith(
      odometer: updatedOdometer,
      rideMemories: updatedMemories ?? ride.rideMemories,
    );
  }

  /// Checks if a path is a local file path (not a URL)
  bool _isLocalPath(String path) {
    return !path.startsWith('http://') && !path.startsWith('https://');
  }

  @override
  Future<RideEntity?> getRecentRide() async {
    try {
      final snapshot = await _userRidesCollection()
          .orderBy('startedAt', descending: true)
          .limit(1) // Only fetch the most recent ride
          .get();

      if (snapshot.docs.isEmpty) return null;

      return RideModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      // Optionally, handle or log the error
      return null;
    }
  }
}
