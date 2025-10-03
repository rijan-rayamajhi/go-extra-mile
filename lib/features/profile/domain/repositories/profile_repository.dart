import 'dart:io';

import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity?> getProfile(String uid);
  Future<ProfileEntity?> getCurrentUserProfile();
  Future<String?> getUserProfileImage(String uid);
  Future<void> updateProfile(
    ProfileEntity profile,
    File? profilePhotoImageFile,
  );
  Future<bool> isUsernameAvailable(String username);
}
