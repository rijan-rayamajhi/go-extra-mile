import 'package:equatable/equatable.dart';
import 'faq.dart';

class CashoutParams extends Equatable {
  final int minimumDistance;
  final int minimumReferrals;
  final int minimumRides;
  final double conversionRate;

  const CashoutParams({
    required this.minimumDistance,
    required this.minimumReferrals,
    required this.minimumRides,
    required this.conversionRate,
  });

  @override
  List<Object?> get props => [
        minimumDistance,
        minimumReferrals,
        minimumRides,
        conversionRate,
      ];
}

class MonetizationSettings extends Equatable {
  final bool allowCashout;
  final double bankBalance;
  final CashoutParams cashoutParams;
  final List<Faq> faqs;
  final double gstPercentage;
  final String id;
  final DateTime lastUpdated;
  final bool limitBasedCashout;
  final double maxLimitCashout;
  final double minCashout;
  final String monetizationMessage;
  final double otherCharge;
  final double platformCharge;
  final List<String> predefinedAmounts;
  final int timeLimit;
  final String updatedBy;

  const MonetizationSettings({
    required this.allowCashout,
    required this.bankBalance,
    required this.cashoutParams,
    required this.faqs,
    required this.gstPercentage,
    required this.id,
    required this.lastUpdated,
    required this.limitBasedCashout,
    required this.maxLimitCashout,
    required this.minCashout,
    required this.monetizationMessage,
    required this.otherCharge,
    required this.platformCharge,
    required this.predefinedAmounts,
    required this.timeLimit,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [
        allowCashout,
        bankBalance,
        cashoutParams,
        faqs,
        gstPercentage,
        id,
        lastUpdated,
        limitBasedCashout,
        maxLimitCashout,
        minCashout,
        monetizationMessage,
        otherCharge,
        platformCharge,
        predefinedAmounts,
        timeLimit,
        updatedBy,
      ];
}
