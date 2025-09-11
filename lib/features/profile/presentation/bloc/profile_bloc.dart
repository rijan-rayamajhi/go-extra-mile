import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/profile/domain/usecases/check_username_availability.dart';
import 'package:go_extra_mile_new/features/profile/domain/usecases/get_profile.dart';
import 'package:go_extra_mile_new/features/profile/domain/usecases/update_profile.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final CheckUsernameAvailability _checkUsernameAvailability;

  ProfileBloc({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required CheckUsernameAvailability checkUsernameAvailability,
  })  : _getProfile = getProfile,
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
      
      final profile = await _getProfile(event.uid);
      
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileNotFound('Profile not found'));
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
      
      emit(ProfileUpdating(event.profile));
      
      await _updateProfile(event.profile, event.profilePhotoImageFile);
      
      
      // Fetch the latest profile from the backend to ensure computed fields are up-to-date
      final refreshedProfile = await _getProfile(event.profile.uid);
      
      if (refreshedProfile != null) {
        emit(ProfileUpdated(refreshedProfile));
      } else {
        // Fallback to the event profile if refresh fails
        emit(ProfileUpdated(event.profile));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onResetProfile(
    ResetProfileEvent event,
    Emitter<ProfileState> emit,
  ) {
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
        emit(const ProfileNotFound('Profile not found'));
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
      emit(UsernameAvailabilityChecking());
      
      final isAvailable = await _checkUsernameAvailability(event.username);
      
      emit(UsernameAvailabilityResult(event.username, isAvailable));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
} 