import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/referral_repository.dart';
import '../models/referral_model.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  final FirebaseFirestore _firestore;

  ReferralRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<Failure, String>> validateReferralCode(String referralCode) async {
    try {
      // Query for user with this referral code
      final querySnapshot = await _firestore
          .collection('users')
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return Left(ServerFailure('Invalid referral code'));
      }

      return Right(querySnapshot.docs.first.id);
    } catch (e) {
      return Left(ServerFailure('Failed to validate referral code'));
    }
  }

  @override
  Future<Either<Failure, void>> processReferralReward({
    required String referrerUserId,
    required String referredUserId,
    required String referralCode,
  }) async {
    try {
      // Start a transaction to update both users' coins
      await _firestore.runTransaction((transaction) async {
        // Update referrer's coins (1000 coins)
        final referrerRef = _firestore.collection('users').doc(referrerUserId);
        final referrerDoc = await transaction.get(referrerRef);
        
        final currentReferrerCoins = referrerDoc.data()?['totalGemCoins'] as int? ?? 0;
        transaction.update(referrerRef, {
          'totalGemCoins': currentReferrerCoins + 1000,
        });

        // Update referred user's coins (100 coins) and mark referral as used
        final referredRef = _firestore.collection('users').doc(referredUserId);
        final referredDoc = await transaction.get(referredRef);
        
        final currentReferredCoins = referredDoc.data()?['totalGemCoins'] as int? ?? 0;
        transaction.update(referredRef, {
          'totalGemCoins': currentReferredCoins + 100,
          'usedReferralCode': referralCode,
          'referralUsed': true, 
        });

        // Record the referral in a separate collection for tracking
        final referralModel = ReferralModel(
          referralCode: referralCode,
          coinsEarned: 100,
          referredByUserId: referrerUserId,
          referredAt: DateTime.now(),
        );

        final referralRef = _firestore  
            .collection('users')
            .doc(referredUserId)
            .collection('referrals')
            .doc();
            
        transaction.set(referralRef, referralModel.toJson());
      });

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to process referral reward'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUsedReferral(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      final hasUsed = docSnapshot.data()?['referralUsed'] as bool? ?? false;
      return Right(hasUsed);
    } catch (e) {
      return Left(ServerFailure('Failed to check referral status'));
    }
  }
} 