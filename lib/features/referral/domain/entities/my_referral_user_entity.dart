import 'package:equatable/equatable.dart';

class MyReferralUserEntity extends Equatable {
  final String userId;
  final String referralCode;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  const MyReferralUserEntity({
    required this.userId,
    required this.referralCode,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        userId,
        referralCode,
        displayName,
        photoUrl,
        createdAt,
      ];
}
