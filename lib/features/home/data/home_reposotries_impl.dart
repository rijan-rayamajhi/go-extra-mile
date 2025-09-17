import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/features/home/domain/home_repositories.dart';
import 'package:go_extra_mile_new/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:go_extra_mile_new/features/profile/data/datasources/profile_data_source.dart';
import 'package:go_extra_mile_new/features/vehicle/data/datasource/vehicle_firestore_datasource.dart';
import 'package:go_extra_mile_new/features/ride/data/datasources/ride_firestore_datasource.dart';
import 'package:go_extra_mile_new/features/ride/data/datasources/ride_local_datasource.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/referral/domain/referal_repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeRepositoriesImpl implements HomeRepository {
  final ProfileDataSource profileDataSource;
  final NotificationRemoteDataSource notificationRemoteDataSource;
  final VehicleFirestoreDataSource vehicleFirestoreDataSource;
  final RideFirestoreDataSource rideFirestoreDataSource;
  final RideLocalDatasource rideLocalDatasource;
  final ReferalRepository referralRepository;
  final FirebaseFirestore _firestore;
  
  HomeRepositoriesImpl(
    this.profileDataSource, 
    this.notificationRemoteDataSource,
    this.vehicleFirestoreDataSource,
    this.rideFirestoreDataSource,
    this.rideLocalDatasource,
    this.referralRepository,
    FirebaseFirestore firestore,
  ) : _firestore = firestore;

  String get _currentUid {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw Exception('User not found');
    }
    return uid;
  }

  @override
  Future<String?> getUserProfileImage() async {
    final uid = _currentUid;
    String? profileImage = await profileDataSource.getUserProfileImage(uid);
    return profileImage;
  }

  @override
  Future<String> getUnreadNotification() async {
    final uid = _currentUid;
    return await notificationRemoteDataSource.getUnreadNotification(uid);
  }
  
  @override
  Future<String> getUnverifiedVehicle() async {
    try {
      final uid = _currentUid;
      final count = await vehicleFirestoreDataSource.getTotalNotVerifiedVehicles(uid);
      return count.toString();
    } catch (e) {
      throw Exception('Failed to get unverified vehicle count: $e');
    }
  }

  @override
  Future<Map<String, List<RideEntity>>> getRecentRides() async {
    try {
      final uid = _currentUid;

      // Fetch both remote and local rides in parallel
      final remoteRidesFuture = rideFirestoreDataSource.getRecentRidesByUserId(uid, limit: 1);
      final localRidesFuture = rideLocalDatasource.getUserRides(uid);

      final results = await Future.wait([
        remoteRidesFuture,
        localRidesFuture,
      ]);

      final remoteRides = results[0];
      final localRides = results[1];

      // Convert remote rides to RideEntity (RideModel extends RideEntity)
      final remoteRideEntities = remoteRides.cast<RideEntity>();

      // Sort local rides by start date (most recent first) and limit them
      localRides.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      final limitedLocalRides = localRides.take(1).toList();

      return {
        'remoteRides': remoteRideEntities,
        'localRides': limitedLocalRides,
      };
    } catch (e) {
      throw Exception('Failed to get recent rides: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Get all users with statistics data
      final usersQuery = await _firestore
          .collection('users')
          .where('totalGemCoins', isGreaterThan: 0)
          .get();

      int totalGemCoins = 0;
      double totalDistance = 0;
      int totalRides = 0;

      for (final doc in usersQuery.docs) {
        final data = doc.data();
        
        // Sum up gem coins
        final gemCoins = (data['totalGemCoins'] as num?)?.toInt() ?? 0;
        totalGemCoins += gemCoins;
        
        // Sum up distance
        final distance = (data['totalDistance'] as num?)?.toDouble() ?? 0;
        totalDistance += distance;
        
        // Sum up rides
        final rides = (data['totalRide'] as num?)?.toInt() ?? 0;
        totalRides += rides;
      }

      return {
        'totalGemCoins': totalGemCoins,
        'totalDistance': totalDistance,
        'totalRides': totalRides,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  @override
  Future<String> getReferralCode() async {
    try {
      return await referralRepository.getReferralCode();
    } catch (e) {
      // Fallback: generate referral code from UID if not found
      final uid = _currentUid;
      return uid.substring(0, 7).toUpperCase();
    }
  }
}