import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/core/constants/firebase_constants.dart';
import '../../domain/entities/app_stats_entity.dart';

abstract class AppStatsFirebaseDatasource {
  Future<AppStatsEntity> getAppStats();
}

class AppStatsFirebaseDatasourceImpl implements AppStatsFirebaseDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<AppStatsEntity> getAppStats() async {
    try {
      // Get all users to calculate total GEM coins
      final usersSnapshot = await _firestore.collection(FirebaseConstants.users).get();
      
      int totalGemCoins = 0;
      double totalDistance = 0.0;
      int totalRides = 0;

      // Calculate total GEM coins from all users
      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final userGemCoins = (userData['totalGemCoins'] as num?)?.toInt() ?? 0;
        totalGemCoins += userGemCoins;

        // Get rides for each user to calculate total distance and rides
        final ridesSnapshot = await _firestore
            .collection(FirebaseConstants.users)
            .doc(userDoc.id)
            .collection(FirebaseConstants.rides)
            .get();

        totalRides += ridesSnapshot.docs.length;

        // Calculate total distance from all rides
        for (var rideDoc in ridesSnapshot.docs) {
          final rideData = rideDoc.data();
          final rideDistance = (rideData['totalDistance'] as num?)?.toDouble() ?? 0.0;
          totalDistance += rideDistance;
        }
      }

      return AppStatsEntity(
        totalGemCoins: totalGemCoins,
        totalDistance: totalDistance,
        totalRides: totalRides,
      );
    } catch (e) {
      throw Exception('Failed to fetch app stats: $e');
    }
  }
}
