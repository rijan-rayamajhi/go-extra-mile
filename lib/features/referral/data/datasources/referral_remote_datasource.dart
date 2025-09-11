import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/core/service/device_info_service.dart';
import '../models/my_referral_user_model.dart';

abstract class ReferralRemoteDataSource {
  Future<void> submitReferralCode(String referralCode);
  Future<String> getReferralCode();
  Future<List<MyReferralUserModel>> getMyReferalUsers();
}

class ReferralRemoteDataSourceImpl implements ReferralRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final DeviceInfoService deviceInfoService;

  ReferralRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.deviceInfoService,
  });

  @override
  Future<void> submitReferralCode(String referralCode) async {
    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }

    final deviceId = await deviceInfoService.getUniqueDeviceId();

    try {
      await firestore
          .runTransaction((transaction) async {
            // Step 1: Find referrer by referralCode
            final referralCodeQuery = await firestore
                .collection('users')
                .where('referral.referralCode', isEqualTo: referralCode)
                .limit(1)
                .get();

            if (referralCodeQuery.docs.isEmpty) {
              throw Exception('Invalid referral code');
            }

            final referrerDoc = referralCodeQuery.docs.first;
            final referrerUserId = referrerDoc.id;
            if (referrerUserId == currentUserId) {
              throw Exception('Cannot use your own referral code');
            }

            // Step 2: Load current user & referrer inside transaction
            final currentUserRef = firestore
                .collection('users')
                .doc(currentUserId);
            final referrerUserRef = firestore
                .collection('users')
                .doc(referrerUserId);

            final currentUserSnap = await transaction.get(currentUserRef);
            final referrerUserSnap = await transaction.get(referrerUserRef);

            if (currentUserSnap.exists) {
              final userData = currentUserSnap.data()!;
              final referral =
                  (userData['referral'] as Map<String, dynamic>?) ?? {};
              

              if (referral['hasUsedReferral'] == true) {
                throw Exception('You have already used a referral code');
              }
            }

            // Check if this device ID has been used by ANY user
            final deviceUsedQuery = await firestore
                .collection('users')
                .where('referral.deviceId', isEqualTo: deviceId)
                .limit(1)
                .get();
            
            if (deviceUsedQuery.docs.isNotEmpty) {
              throw Exception('This device has already been used for a referral');
            }

            if (referrerUserSnap.exists) {
              final referrerData = referrerUserSnap.data()!;
              final referral =
                  (referrerData['referral'] as Map<String, dynamic>?) ?? {};
              final usedBy =
                  (referral['referralUsedBy'] as List<dynamic>? ?? []);
              

              final alreadyUsed = usedBy.any(
                (r) {
                  if (r is Map<String, dynamic>) {
                    final storedDeviceId = r['deviceId'];
                    return storedDeviceId == deviceId;
                  }
                  return false;
                },
              );
              

              if (alreadyUsed) {
                throw Exception(
                  'This device has already been used for a referral',
                );
              }
            }

            // Step 3: Update current user (mark referral used)
            transaction.set(currentUserRef, {
              'referral': {
                'hasUsedReferral': true,
                'referralUsedTimestamp': DateTime.now(),
                'referralCodeUsed': referralCode,
                'referredBy': referrerUserId,
                'deviceId': deviceId,
              },
            }, SetOptions(merge: true));

            // Step 4: Update referrer (add referral info)
            final referralData = {
              'userId': currentUserId,
              'deviceId': deviceId,
              'timestamp': DateTime.now(),
              'referralCode': referralCode,
            };
            
            
            transaction.set(referrerUserRef, {
              'referral': {
                'referralUsedBy': FieldValue.arrayUnion([referralData]),
                'totalReferrals': FieldValue.increment(1),
                'lastReferralTimestamp': DateTime.now(),
              },
            }, SetOptions(merge: true));
          })
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      // Re-throw specific exceptions as-is
      if (e.toString().contains('Cannot use your own referral code') ||
          e.toString().contains('Invalid referral code') ||
          e.toString().contains('already used a referral code') ||
          e.toString().contains('already been used for a referral') ||
          e.toString().contains('User not authenticated')) {
        rethrow;
      }
      throw Exception('Failed to submit referral code. Please try again.');
    }
  }
 
  @override
  Future<String> getReferralCode() async {
    final String referralCode = await firestore.collection('users').doc(firebaseAuth.currentUser?.uid).get().then((value) => value.data()?['referral']['referralCode'] ?? '');
    if (referralCode.isEmpty) {
      throw Exception('No referral code found');
    }
    return referralCode;
  }

  @override
  Future<List<MyReferralUserModel>> getMyReferalUsers() async {
    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('User not authenticated. Please sign in again.');
    }

    try {
      // Get the current user's referral data
      final currentUserDoc = await firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!currentUserDoc.exists) {
        return [];
      }

      final userData = currentUserDoc.data()!;
      final referralData = userData['referral'] as Map<String, dynamic>?;
      final referralUsedBy = referralData?['referralUsedBy'] as List<dynamic>? ?? [];

      final List<MyReferralUserModel> myReferralUsers = [];

      // For each referred user, get their profile information
      for (var referralInfo in referralUsedBy) {
        if (referralInfo is Map<String, dynamic>) {
          final referredUserId = referralInfo['userId'] as String?;
          if (referredUserId != null) {
            try {
              // Get the referred user's profile data
              final referredUserDoc = await firestore
                  .collection('users')
                  .doc(referredUserId)
                  .get();

              if (referredUserDoc.exists) {
                final referredUserData = referredUserDoc.data()!;
                final myReferralUser = MyReferralUserModel.fromFirestoreData(
                  referralInfo,
                  referredUserData,
                );
                myReferralUsers.add(myReferralUser);
              }
            } catch (e) {
              // Skip this user if there's an error fetching their data
              continue;
            }
          }
        }
      }

      return myReferralUsers;
    } catch (e) {
      throw Exception('Failed to fetch referral users. Please try again.');
    }
  }
}
