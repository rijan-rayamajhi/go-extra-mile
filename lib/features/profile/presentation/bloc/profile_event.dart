import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetProfileEvent extends ProfileEvent {
  const GetProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileEntity profile;
  final File? profilePhotoImageFile;

  const UpdateProfileEvent(this.profile, {this.profilePhotoImageFile});

  @override
  List<Object?> get props => [profile];
}

class ResetProfileEvent extends ProfileEvent {}

class RefreshProfileEvent extends ProfileEvent {
  final String uid;

  const RefreshProfileEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}

class ToggleProfilePrivacyEvent extends ProfileEvent {
  final String uid;
  final bool isPrivate;

  const ToggleProfilePrivacyEvent(this.uid, this.isPrivate);

  @override
  List<Object?> get props => [uid, isPrivate];
}

class CheckUsernameAvailabilityEvent extends ProfileEvent {
  final String username;

  const CheckUsernameAvailabilityEvent(this.username);

  @override
  List<Object?> get props => [username];
}
