import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/profile/domain/usecases/check_username_availability.dart';
import 'package:go_extra_mile_new/features/profile/domain/usecases/get_profile.dart';
import 'package:go_extra_mile_new/features/profile/domain/usecases/get_current_user_profile.dart';
import 'package:go_extra_mile_new/features/profile/domain/usecases/update_profile.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final GetCurrentUserProfile _getCurrentUserProfile;
  final UpdateProfile _updateProfile;
  final CheckUsernameAvailability _checkUsernameAvailability;

  ProfileBloc({
    required GetProfile getProfile,
    required GetCurrentUserProfile getCurrentUserProfile,
    required UpdateProfile updateProfile,
    required CheckUsernameAvailability checkUsernameAvailability,
  }) : _getProfile = getProfile,
       _getCurrentUserProfile = getCurrentUserProfile,
       _updateProfile = updateProfile,
       _checkUsernameAvailability = checkUsernameAvailability,
       super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ResetProfileEvent>(_onResetProfile);
    on<RefreshProfileEvent>(_onRefreshProfile);
    on<CheckUsernameAvailabilityEvent>(_onCheckUsernameAvailability);
  }

  Future<void> _onGetProfile(
    GetProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());

      final profile = await _getCurrentUserProfile();

      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('Profile not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // Get current state to preserve it
      final currentState = state;
      final currentProfile = currentState is ProfileLoaded ? currentState.profile : event.profile;
      
      // Emit updating state
      emit(ProfileLoaded(currentProfile, isUpdating: true));

      await _updateProfile(event.profile, event.profilePhotoImageFile);

      // Fetch the latest profile from the backend to ensure computed fields are up-to-date
      final refreshedProfile = await _getProfile(event.profile.uid);

      if (refreshedProfile != null) {
        emit(ProfileLoaded(refreshedProfile, justUpdated: true));
      } else {
        // Fallback to the event profile if refresh fails
        emit(ProfileLoaded(event.profile, justUpdated: true));
      }
    } catch (e) {
      // Keep profile data even on error
      final currentState = state;
      final currentProfile = currentState is ProfileLoaded ? currentState.profile : null;
      emit(ProfileError(e.toString(), profile: currentProfile));
    }
  }

  void _onResetProfile(ResetProfileEvent event, Emitter<ProfileState> emit) {
    emit(ProfileInitial());
  }

  Future<void> _onRefreshProfile(
    RefreshProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoading());

      final profile = await _getProfile(event.uid);

      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError('Profile not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onCheckUsernameAvailability(
    CheckUsernameAvailabilityEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // Preserve current profile state while checking username
      final currentState = state;
      if (currentState is ProfileLoaded) {
        emit(currentState.copyWith(
          usernameBeingChecked: event.username,
          clearUsernameCheck: false,
        ));

        final isAvailable = await _checkUsernameAvailability(event.username);

        emit(currentState.copyWith(
          usernameBeingChecked: event.username,
          isUsernameAvailable: isAvailable,
        ));
      }
    } catch (e) {
      final currentState = state;
      final currentProfile = currentState is ProfileLoaded ? currentState.profile : null;
      emit(ProfileError(e.toString(), profile: currentProfile));
    }
  }
}
