import 'dart:io';

import '../repositories/profile_repository.dart';
import '../entities/profile_entity.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<void> call(ProfileEntity profile, File? profilePhotoImageFile) {
    return repository.updateProfile(profile, profilePhotoImageFile);
  }
}
