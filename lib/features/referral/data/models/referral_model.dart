import 'package:cloud_firestore/cloud_firestore.dart';

class ReferralModel {
  final String referralCode;
  final int coinsEarned;
  final String referredByUserId;
  final DateTime referredAt;

  ReferralModel({
    required this.referralCode,
    required this.coinsEarned,
    required this.referredByUserId,
    required this.referredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'coinsEarned': coinsEarned,
      'referredByUserId': referredByUserId,
      'referredAt': Timestamp.fromDate(referredAt),
    };
  }

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      referralCode: json['referralCode'] as String,
      coinsEarned: json['coinsEarned'] as int,
      referredByUserId: json['referredByUserId'] as String,
      referredAt: (json['referredAt'] as Timestamp).toDate(),
    );
  }
} 