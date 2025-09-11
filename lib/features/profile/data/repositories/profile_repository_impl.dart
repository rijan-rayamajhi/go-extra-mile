import 'dart:io';

import 'package:go_extra_mile_new/features/profile/data/datasources/profile_data_source.dart';
import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';
import 'package:go_extra_mile_new/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource dataSource;

  ProfileRepositoryImpl(this.dataSource);

  @override
  Future<ProfileEntity?> getProfile(String uid) async {
    return await dataSource.getProfile(uid);
  }

  @override
  Future<String?> getUserProfileImage(String uid) async {
    return await dataSource.getUserProfileImage(uid);
  }

  @override
  Future<void> updateProfile(ProfileEntity profile, File? profilePhotoImageFile) async {
    return await dataSource.updateProfile(profile, profilePhotoImageFile);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    return await dataSource.isUsernameAvailable(username);
  }
}
