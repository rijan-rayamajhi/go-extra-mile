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
  final bool isUpdating;
  final bool justUpdated;
  final String? usernameBeingChecked;
  final bool? isUsernameAvailable;

  const ProfileLoaded(
    this.profile, {
    this.isUpdating = false,
    this.justUpdated = false,
    this.usernameBeingChecked,
    this.isUsernameAvailable,
  });

  ProfileLoaded copyWith({
    ProfileEntity? profile,
    bool? isUpdating,
    bool? justUpdated,
    String? usernameBeingChecked,
    bool? isUsernameAvailable,
    bool clearUsernameCheck = false,
  }) {
    return ProfileLoaded(
      profile ?? this.profile,
      isUpdating: isUpdating ?? this.isUpdating,
      justUpdated: justUpdated ?? this.justUpdated,
      usernameBeingChecked: clearUsernameCheck ? null : (usernameBeingChecked ?? this.usernameBeingChecked),
      isUsernameAvailable: clearUsernameCheck ? null : (isUsernameAvailable ?? this.isUsernameAvailable),
    );
  }

  @override
  List<Object?> get props => [
        profile,
        isUpdating,
        justUpdated,
        usernameBeingChecked,
        isUsernameAvailable,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  final ProfileEntity? profile; // Keep profile data even during errors

  const ProfileError(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}
