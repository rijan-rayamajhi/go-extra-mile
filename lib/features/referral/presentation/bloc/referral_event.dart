import 'package:equatable/equatable.dart';

abstract class ReferralEvent extends Equatable {
  const ReferralEvent();

  @override
  List<Object?> get props => [];
}

class SubmitReferralCodeEvent extends ReferralEvent {
  final String referralCode;

  const SubmitReferralCodeEvent(this.referralCode);

  @override
  List<Object?> get props => [referralCode];
}

class GetReferralDataEvent extends ReferralEvent {}


class ResetReferralEvent extends ReferralEvent {}
