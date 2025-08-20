import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override List<Object?> get props => [];
}

class SignInWithGoogleEvent extends AuthEvent {}
class SignOutEvent extends AuthEvent {}
class CheckAuthStatusEvent extends AuthEvent {}


