import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';
import '../../../../core/service/firebase_firestore_service.dart';

/// DataSource for managing user data in Firestore after authentication
class UserFirestoreDataSource {
  final FirebaseFirestoreService _firestoreService;

  UserFirestoreDataSource({required FirebaseFirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Creates or updates user profile in Firestore after authentication
  Future<void> createOrUpdateUserProfile({
    required UserEntity user,
    Map<String, dynamic>? additionalData,
  }) async {
    // Extract username from email (part before @ symbol)
    final userName = user.email?.split('@').first ?? 'user';
    
    final userData = {
      'uid': user.uid,
      'userName': userName,
      'displayName': user.displayName,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'isActive': true,
      'privateProfile': false,
      'totalGemCoins': 0,
      'totalRide': 0,
      'totalDistance': 0,
      'referralCode': user.uid.substring(0, 7).toUpperCase(), // Simple referral code using first 6 chars of UID, all capital
      ...?additionalData,
    };
    await _firestoreService.setDocument(
      docPath: 'users/${user.uid}',
      data: userData,
      merge: true, // Merge with existing data if document exists
    );
  }

  /// Updates last login time
  Future<void> updateLastLogin(String userId) async {
    await _firestoreService.updateDocument(
      docPath: 'users/$userId',
      data: {'lastLoginAt': FieldValue.serverTimestamp()},
    );
  }

  /// Gets user profile data
  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await _firestoreService.getDocument(docPath: 'users/$userId');
    
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return UserModel(
      uid: data['uid'] ?? userId,
      userName: data['userName'],
      displayName: data['displayName'],
      email: data['email'],
      photoUrl: data['photoUrl'],
    );
  }

  /// Helper method to delete user rides (uncomment when rides collection exists)
  // Future<void> _deleteUserRides(String userId) async {
  //   final ridesQuery = await _firestoreService.getCollection(
  //     collectionPath: 'rides',
  //     queryBuilder: (query) => query.where('userId', isEqualTo: userId),
  //   );
  //   
  //   for (final doc in ridesQuery.docs) {
  //     await _firestoreService.deleteDocument(docPath: 'rides/${doc.id}');
  //   }
  // }

  /// Helper method to delete user rewards (uncomment when rewards collection exists)
  // Future<void> _deleteUserRewards(String userId) async {
  //   final rewardsQuery = await _firestoreService.getCollection(
  //     collectionPath: 'rewards',
  //     queryBuilder: (query) => query.where('userId', isEqualTo: userId),
  //   );
  //   
  //   for (final doc in rewardsQuery.docs) {
  //     await _firestoreService.deleteDocument(docPath: 'rewards/${doc.id}');
  //   }
  // }

  /// Helper method to delete user achievements (uncomment when achievements collection exists)
  // Future<void> _deleteUserAchievements(String userId) async {
  //   final achievementsQuery = await _firestoreService.getCollection(
  //     collectionPath: 'achievements',
  //     queryBuilder: (query) => query.where('userId', isEqualTo: userId),
  //   );
  //   
  //   for (final doc in achievementsQuery.docs) {
  //     await _firestoreService.deleteDocument(docPath: 'achievements/${doc.id}');
  //   }
  // }

  /// Helper method to delete user settings (uncomment when settings collection exists)
  // Future<void> _deleteUserSettings(String userId) async {
  //   final settingsQuery = await _firestoreService.getCollection(
  //     collectionPath: 'settings',
  //     queryBuilder: (query) => query.where('userId', isEqualTo: userId),
  //   );
  //   
  //   for (final doc in settingsQuery.docs) {
  //     await _firestoreService.deleteDocument(docPath: 'settings/${doc.id}');
  //   }
  // }

  /// Gets information about a deleted user (for admin audit purposes)

}