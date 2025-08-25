abstract class ReferralEvent {
  const ReferralEvent();
}

class SubmitReferralCode extends ReferralEvent {
  final String referralCode;

  const SubmitReferralCode(this.referralCode);
}

class SkipReferral extends ReferralEvent {
  const SkipReferral();
} 