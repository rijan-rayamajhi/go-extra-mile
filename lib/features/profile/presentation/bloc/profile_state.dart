import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdating extends ProfileState {
  final ProfileEntity profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends ProfileState {
  final ProfileEntity profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileNotFound extends ProfileState {
  final String message;

  const ProfileNotFound(this.message);

  @override
  List<Object?> get props => [message];
}

class UsernameAvailabilityChecking extends ProfileState {}

class UsernameAvailabilityResult extends ProfileState {
  final String username;
  final bool isAvailable;

  const UsernameAvailabilityResult(this.username, this.isAvailable);

  @override
  List<Object?> get props => [username, isAvailable];
} 