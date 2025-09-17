import '../../ride/domain/entities/ride_entity.dart';

abstract class HomeRepository {
  Future<String?> getUserProfileImage();
  Future<String>  getUnreadNotification();
  Future<String> getUnverifiedVehicle();
  
  /// Get recent rides for home screen display
  /// Returns a map with 'remoteRides' and 'localRides' keys
  Future<Map<String, List<RideEntity>>> getRecentRides();
  
  /// Get statistics for all users (gem coins, distance, rides)
  Future<Map<String, dynamic>> getStatistics();
  
  /// Get user's referral code
  Future<String> getReferralCode();
}