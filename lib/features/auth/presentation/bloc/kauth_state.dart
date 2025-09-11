import 'package:equatable/equatable.dart';
import '../../domain/entities/account_deletion_info.dart';

abstract class KAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KAuthInitial extends KAuthState {}

class KAuthLoading extends KAuthState {}

class KAuthFailure extends KAuthState {
  final String message;
  KAuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class KAuthAuthenticated extends KAuthState {}

class KAuthDeletedUser extends KAuthState {
  final AccountDeletionInfo deletionInfo;
  KAuthDeletedUser(this.deletionInfo);
  @override
  List<Object?> get props => [deletionInfo];
}

class KAuthNewUser extends KAuthState {}


