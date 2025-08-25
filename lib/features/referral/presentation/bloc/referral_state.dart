abstract class ReferralState {
  const ReferralState();
}

class ReferralInitial extends ReferralState {
  const ReferralInitial();
}

class ReferralLoading extends ReferralState {
  const ReferralLoading();
}

class ReferralSuccess extends ReferralState {
  final int coinsEarned;

  const ReferralSuccess({required this.coinsEarned});
}

class ReferralError extends ReferralState {
  final String message;

  const ReferralError(this.message);
}

class ReferralSkipped extends ReferralState {
  const ReferralSkipped();
} 