import 'package:equatable/equatable.dart';
import '../../domain/entities/my_referral_user_entity.dart';

abstract class ReferralState extends Equatable {
  const ReferralState();

  @override
  List<Object?> get props => [];
}

class ReferralInitial extends ReferralState {}

class ReferralLoading extends ReferralState {}

class ReferralSuccess extends ReferralState {
  final String message;

  const ReferralSuccess({this.message = 'Referral code submitted successfully!'});

  @override
  List<Object?> get props => [message];
}

class ReferralDataLoaded extends ReferralState {
  final String referralCode;
  final List<MyReferralUserEntity> myReferalUsers;

  const ReferralDataLoaded(this.referralCode, this.myReferalUsers);

  @override
  List<Object?> get props => [referralCode];
}


class ReferralError extends ReferralState {
  final String message;

  const ReferralError(this.message);

  @override
  List<Object?> get props => [message];
}
