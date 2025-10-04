import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/odometer_entity.dart';
import 'package:go_extra_mile_new/features/referral/domain/entities/my_referral_user_entity.dart';
import 'cashout_transaction_entity.dart';

class MonetizationDataEntity extends Equatable {
  final DrivingLicenseEntity? drivingLicense;
  final List<VehicleEntity> vehicles;
  final List<RideEntity> rides;
  final List<MyReferralUserEntity> referralUsers;
  final double totalGemCoins;
  final bool? isMonetizedFromDB; // Database field for manual monetization override

  const MonetizationDataEntity({
    this.drivingLicense,
    this.vehicles = const [],
    this.rides = const [],
    this.referralUsers = const [],
    this.totalGemCoins = 0.0,
    this.isMonetizedFromDB,
  });

  // Helper methods to check verification status
  bool get isDLVerified => 
      drivingLicense?.verificationStatus == DrivingLicenseVerificationStatus.verified;

  bool get hasVerifiedVehicle => 
      vehicles.any((vehicle) => vehicle.verificationStatus == VehicleVerificationStatus.verified);

  int get verifiedRidesCount => 
      rides.where((ride) => ride.odometer?.verificationStatus == OdometerVerificationStatus.verified).length;

  double get totalVerifiedDistance => 
      rides.where((ride) => ride.odometer?.verificationStatus == OdometerVerificationStatus.verified)
           .fold(0.0, (sum, ride) => sum + (ride.totalDistance ?? 0.0));

  int get referralCount => referralUsers.length;

  // Calculate available GEM coins based on total coins and used coins from cashout transactions
  double calculateAvailableGemCoins(List<CashoutTransactionEntity> cashoutTransactions) {
    final nonRejectedTransactions = cashoutTransactions
        .where((transaction) => transaction.status != CashoutTransactionStatus.rejected)
        .toList();
    
    final totalUsedGemCoins = nonRejectedTransactions
        .fold(0.0, (sum, transaction) => sum + transaction.gemCoinsUsed);
    
    return totalGemCoins - totalUsedGemCoins;
  }

  // Check if user meets all monetization requirements
  bool isMonetized({
    required int targetDistance,
    required int targetReferrals,
    required int targetRides,
  }) {
    return isDLVerified &&
           hasVerifiedVehicle &&
           totalVerifiedDistance >= targetDistance &&
           referralCount >= targetReferrals &&
           verifiedRidesCount >= targetRides;
  }

  @override
  List<Object?> get props => [
    drivingLicense,
    vehicles,
    rides,
    referralUsers,
    totalGemCoins,
    isMonetizedFromDB,
  ];
}
