import 'package:equatable/equatable.dart';

abstract class KAuthEvent extends Equatable {
  @override List<Object?> get props => [];
}


class KSignInWithGoogleEvent extends KAuthEvent {}
class KSignInWithAppleEvent extends KAuthEvent {}
class KSignOutEvent extends KAuthEvent {}
class KDeleteAccountEvent extends KAuthEvent {
  final String uid;
  final String reason;
  KDeleteAccountEvent(this.uid, this.reason);
  @override List<Object?> get props => [uid, reason];
}

class KCheckAuthStatusEvent extends KAuthEvent {}

class KRestoreAccountEvent extends KAuthEvent {
  final String uid;
  KRestoreAccountEvent(this.uid);
  @override List<Object?> get props => [uid];
}





