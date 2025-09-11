import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/my_referral_user_entity.dart';

class MyReferralUserModel extends MyReferralUserEntity {
  const MyReferralUserModel({
    required super.userId,
    required super.referralCode,
    super.displayName,
    super.photoUrl,
    super.createdAt,
  });

  factory MyReferralUserModel.fromMap(Map<String, dynamic> map) {
    return MyReferralUserModel(
      userId: map['userId'] ?? '',
      referralCode: map['referralCode'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  factory MyReferralUserModel.fromFirestoreData(Map<String, dynamic> referralData, Map<String, dynamic> userData) {
    return MyReferralUserModel(
      userId: referralData['userId'] ?? '',
      referralCode: referralData['referralCode'] ?? '',
      displayName: userData['displayName'],
      photoUrl: userData['photoUrl'],
      createdAt: (userData['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'referralCode': referralCode,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  MyReferralUserModel copyWith({
    String? userId,
    String? referralCode,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return MyReferralUserModel(
      userId: userId ?? this.userId,
      referralCode: referralCode ?? this.referralCode,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
