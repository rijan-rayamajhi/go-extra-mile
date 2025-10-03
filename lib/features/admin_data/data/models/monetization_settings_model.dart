import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/monetization_settings.dart';
import 'faq_model.dart';

class CashoutParamsModel extends CashoutParams {
  const CashoutParamsModel({
    required super.minimumDistance,
    required super.minimumReferrals,
    required super.minimumRides,
    required super.conversionRate,
  });

  factory CashoutParamsModel.fromJson(
    Map<String, dynamic> json, {
    double? rootConversionRate,
  }) {
    return CashoutParamsModel(
      minimumDistance: (json['minimumDistance'] as num).toInt(),
      minimumReferrals: (json['minimumReferrals'] as num).toInt(),
      minimumRides: (json['minimumRides'] as num).toInt(),
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ??
          rootConversionRate ??
          1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minimumDistance': minimumDistance,
      'minimumReferrals': minimumReferrals,
      'minimumRides': minimumRides,
      'conversionRate': conversionRate,
    };
  }
}

class MonetizationSettingsModel extends MonetizationSettings {
  const MonetizationSettingsModel({
    required super.allowCashout,
    required super.bankBalance,
    required super.cashoutParams,
    required super.faqs,
    required super.gstPercentage,
    required super.id,
    required super.lastUpdated,
    required super.limitBasedCashout,
    required super.maxLimitCashout,
    required super.minCashout,
    required super.monetizationMessage,
    required super.otherCharge,
    required super.platformCharge,
    required super.predefinedAmounts,
    required super.timeLimit,
    required super.updatedBy,
  });

  factory MonetizationSettingsModel.fromJson(Map<String, dynamic> json) {
    return MonetizationSettingsModel(
      allowCashout: json['allowCashout'] ?? true,
      bankBalance: (json['bankBalance'] as num?)?.toDouble() ?? 0.0,
      cashoutParams: json['cashoutParams'] != null
          ? CashoutParamsModel.fromJson(
              json['cashoutParams'] as Map<String, dynamic>,
              rootConversionRate: (json['conversionRate'] as num?)?.toDouble(),
            )
          : CashoutParamsModel(
              minimumDistance: 0,
              minimumReferrals: 0,
              minimumRides: 0,
              conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 1.0,
            ),
      faqs:
          (json['faqs'] as List<dynamic>?)
              ?.map((faq) => FaqModel.fromJson(faq as Map<String, dynamic>))
              .toList() ??
          [],
      gstPercentage: (json['gstPercentage'] as num?)?.toDouble() ?? 18.0,
      id: json['id'] ?? 'default',
      lastUpdated:
          (json['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      limitBasedCashout: json['limitBasedCashout'] ?? true,
      maxLimitCashout: (json['maxLimitCashout'] as num?)?.toDouble() ?? 0.0,
      minCashout: (json['minCashout'] as num?)?.toDouble() ?? 1.0,
      monetizationMessage: json['monetizationMessage'] ?? '',
      otherCharge: (json['otherCharge'] as num?)?.toDouble() ?? 0.0,
      platformCharge: (json['platformCharge'] as num?)?.toDouble() ?? 0.0,
      predefinedAmounts:
          (json['predefinedAmounts'] as List<dynamic>?)
              ?.map((amount) => amount.toString())
              .toList() ??
          [],
      timeLimit: (json['timeLimit'] as num?)?.toInt() ?? 30,
      updatedBy: json['updatedBy'] ?? 'admin',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowCashout': allowCashout,
      'bankBalance': bankBalance,
      'cashoutParams': {
        'minimumDistance': cashoutParams.minimumDistance,
        'minimumReferrals': cashoutParams.minimumReferrals,
        'minimumRides': cashoutParams.minimumRides,
        // Note: conversionRate is stored at root level, not in cashoutParams
      },
      'conversionRate': cashoutParams.conversionRate, // Store at root level
      'faqs': faqs
          .map(
            (faq) => FaqModel(
              id: faq.id,
              question: faq.question,
              answer: faq.answer,
            ).toJson(),
          )
          .toList(),
      'gstPercentage': gstPercentage,
      'id': id,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'limitBasedCashout': limitBasedCashout,
      'maxLimitCashout': maxLimitCashout,
      'minCashout': minCashout,
      'monetizationMessage': monetizationMessage,
      'otherCharge': otherCharge,
      'platformCharge': platformCharge,
      'predefinedAmounts': predefinedAmounts,
      'timeLimit': timeLimit,
      'updatedBy': updatedBy,
    };
  }
}
