import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/core/error/failures.dart';
import 'package:go_extra_mile_new/features/license/domain/usecases/get_driving_license.dart';
import 'package:go_extra_mile_new/features/monetization/data/models/cashout_transaction_model.dart';
import 'package:go_extra_mile_new/features/monetization/domain/entities/cashout_transaction_entity.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/usecases/get_user_vehicles.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/ride/domain/usecases/get_all_firebase_rides.dart';
import 'package:go_extra_mile_new/features/referral/domain/usecases/get_my_referral_data.dart';
import 'package:go_extra_mile_new/features/referral/domain/entities/my_referral_user_entity.dart';
import '../../domain/entities/monetization_data_entity.dart';
import '../../domain/repositories/monetization_repository.dart';

class MonetizationDataRepositoryImpl implements MonetizationRepository {
  final GetDrivingLicense getDrivingLicense;
  final GetUserVehicles getUserVehicles;
  final GetAllFirebaseRides getAllFirebaseRides;
  final GetMyReferralData getMyReferralData;

  MonetizationDataRepositoryImpl({
    required this.getDrivingLicense,
    required this.getUserVehicles,
    required this.getAllFirebaseRides,
    required this.getMyReferralData,
  });

  @override
  Future<Either<Failure, MonetizationDataEntity>> getMonetizationData() async {
    try {
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      // Get driving license data
      final licenseResult = await getDrivingLicense();
      final drivingLicense = licenseResult.fold(
        (failure) => null,
        (license) => license,
      );

      // Get vehicles data
      final vehiclesResult = await getUserVehicles(currentUser.uid);
      final vehicles = vehiclesResult.fold(
        (failure) => <VehicleEntity>[],
        (vehiclesList) => vehiclesList,
      );

      // Get rides data
      final rides = await getAllFirebaseRides();

      // Get referral data
      final referralData = await getMyReferralData();
      final referralUsers = (referralData['myReferalUsers'] as List<dynamic>?)
          ?.cast<MyReferralUserEntity>() ??
      <MyReferralUserEntity>[];

      // Fetch user's total GEM coins and monetization status from Firestore
      double totalGemCoins = 0.0;
      bool? isMonetizedFromDB;
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          totalGemCoins = (userData['totalGemCoins'] as num?)?.toDouble() ?? 0.0;
          isMonetizedFromDB = userData['isMonetized'] as bool?;
        }
      } catch (e) {
        // If fetching user data fails, continue with defaults
        totalGemCoins = 0.0;
        isMonetizedFromDB = null;
      }

      return Right(
        MonetizationDataEntity(
          drivingLicense: drivingLicense,
          vehicles: vehicles,
          rides: rides,
          referralUsers: referralUsers,
          totalGemCoins: totalGemCoins,
          isMonetizedFromDB: isMonetizedFromDB,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateMonetizationStatus(
    bool isMonetized,
  ) async {
    try {
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      ///update using collection path
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'isMonetized': isMonetized});
      return Right(isMonetized);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> getMonetizationStatus() async {
    try {
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      final monetizationStatus = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return Right(monetizationStatus.data()!['isMonetized'] ?? false);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createCashoutTransaction(
    CashoutTransactionEntity cashoutTransactionEntity,
  ) async {
    try {
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      // Convert entity to model for Firestore operations
      final cashoutModel = CashoutTransactionModel(
        id: cashoutTransactionEntity.id,
        amount: cashoutTransactionEntity.amount,
        gemCoinsUsed: cashoutTransactionEntity.gemCoinsUsed,
        createdAt: cashoutTransactionEntity.createdAt,
        updatedAt: cashoutTransactionEntity.updatedAt,
        userUpiId: cashoutTransactionEntity.userUpiId,
        userFullName: cashoutTransactionEntity.userFullName,
        userPhoneNumber: cashoutTransactionEntity.userPhoneNumber,
        userWhatsAppNumber: cashoutTransactionEntity.userWhatsAppNumber,
        status: cashoutTransactionEntity.status,
      );

      // Use Firestore batch for atomic operations
      final batch = FirebaseFirestore.instance.batch();

      // 1. Generate numeric transaction ID
      final numericId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Create cashout transaction document with numeric ID
      final cashoutRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cashout_transactions')
          .doc(numericId);

      // Update the model with the numeric ID
      final updatedCashoutModel = cashoutModel.copyWith(id: numericId);
      batch.set(cashoutRef, updatedCashoutModel.toFirestore());

      // 2. Create GEM coin debit transaction
      final gemCoinRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('gem_coin_history')
          .doc();

      final gemCoinTransaction = {
        'type': 'debit',
        'rewardType': 'otherReward',
        'amount': cashoutTransactionEntity.gemCoinsUsed,
        'reason': 'Cashout transaction - ₹${cashoutTransactionEntity.amount}',
        'date': Timestamp.fromDate(DateTime.now()),
      };

      batch.set(gemCoinRef, gemCoinTransaction);

      // 3. Deduct amount from admin bank balance
      final adminRef = FirebaseFirestore.instance
          .collection('admin_data')
          .doc('monetization_settings');

      // Check if admin document exists first
      final adminDoc = await adminRef.get();
      if (adminDoc.exists) {
        // Use FieldValue.increment to atomically decrease the bank balance
        batch.update(adminRef, {
          'bankBalance': FieldValue.increment(-cashoutTransactionEntity.amount),
        });
      } else {
        // Create the document with initial bank balance if it doesn't exist
        batch.set(adminRef, {
          'bankBalance': -cashoutTransactionEntity.amount, // Start with negative amount
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CashoutTransactionEntity>>>
  getCashoutTransactions() async {
    try {
      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        return const Left(ServerFailure('User not authenticated'));
      }

      // Fetch cashout transactions from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('cashout_transactions')
          .orderBy('createdAt', descending: true)
          .get();

      // Convert Firestore documents to entities
      final transactions = snapshot.docs
          .map((doc) => CashoutTransactionModel.fromFirestore(doc))
          .cast<CashoutTransactionEntity>()
          .toList();

      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
