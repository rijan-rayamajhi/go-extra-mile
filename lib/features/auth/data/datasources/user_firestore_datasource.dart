import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/account_deletion_info.dart';
import '../models/account_deletion_info_model.dart';
import '../../../../core/service/firebase_firestore_service.dart';

/// DataSource for managing user data in Firestore after authentication
class UserFirestoreDataSource {
  final FirebaseFirestoreService _firestoreService;

  UserFirestoreDataSource({required FirebaseFirestoreService firestoreService})
    : _firestoreService = firestoreService;

  /// Creates or updates user profile in Firestore after authentication
  Future<void> createUserProfile({
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
      'referral' : {
      'referralCode': user.uid
          .substring(0, 7)
          .toUpperCase(), // Simple referral code using first 6 chars of UID, all capital
      },
      'fcmToken': 'soon',
      ...?additionalData,
    };
    await _firestoreService.setDocument(
      docPath: 'users/${user.uid}',
      data: userData,
    );
  }

  /// Checks if a user document exists in the users collection
  Future<bool> checkIfUserExists(String uid) async {
    try {
      final docSnapshot = await _firestoreService.getDocument(
        docPath: 'users/$uid',
      );
      return docSnapshot.exists;
    } catch (e) {
      throw Exception('Failed to check if user exists: $e');
    }
  }

  /// Checks if a user account has been deleted by looking in the deleted accounts collection
  Future<AccountDeletionInfo?> checkIfAccountDeleted(String uid) async {
    try {
      final docSnapshot = await _firestoreService.getDocument(
        docPath: 'accounts_deletion_requests/$uid',
      );
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data() as Map<String, dynamic>;
      return AccountDeletionInfoModel.fromFirestore(data);
    } catch (e) {
      throw Exception('Failed to check if account is deleted: $e');
    }
  }

 /// Deletes a user account from the users collection
 Future<void> deleteUserAccount(String uid , String reason) async {
  //create `deleted_users` collection
  final deletionInfo = AccountDeletionInfoModel(
    uid: uid,
    reason: reason,
    createdAt: DateTime.now(),
  );
  
  await _firestoreService.setDocument(
    docPath: 'accounts_deletion_requests/$uid',
    data: deletionInfo.toFirestore(),
  );
 }

 /// Restores a user account from the deleted accounts collection
 Future<void> restoreUserAccount(String uid) async {
  await _firestoreService.deleteDocument(
    docPath: 'accounts_deletion_requests/$uid',
  );
 }
}
