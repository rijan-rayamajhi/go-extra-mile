import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/core/constants/firebase_constants.dart';
import 'package:go_extra_mile_new/core/service/firebase_storage_service.dart';
import 'package:go_extra_mile_new/features/profile/data/model/profile_model.dart';
import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';
import 'package:go_extra_mile_new/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorageService firebaseStorageService;

  ProfileRepositoryImpl(this.firestore, this.firebaseStorageService);

  @override
  Future<ProfileEntity?> getProfile(String uid) async {
    final doc = await firestore.collection(usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return ProfileModel.fromMap(doc.data()!);
  }

  @override
  Future<void> updateProfile(ProfileEntity profile, File? profilePhotoImageFile) async {
    // This method handles partial updates - only fields that are not null will be updated
    // This allows the edit profile screen to update only specific fields without affecting others
    
    // Create a map with only the fields that are being updated
    final updateData = <String, dynamic>{};
    
    // Handle profile photo upload if provided
    if (profilePhotoImageFile != null) {
      try {
        // Generate a unique path for the profile photo
        final photoPath = 'users/${profile.uid}/profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Upload the photo to Firebase Storage
        final photoUrl = await firebaseStorageService.uploadFile(
          file: profilePhotoImageFile,
          path: photoPath,
        );
        
        // Add the photo URL to the update data
        updateData['photoUrl'] = photoUrl;
      } catch (e) {
        // If photo upload fails, rethrow the error
        rethrow;
      }
    } else {
      updateData['photoUrl'] = profile.photoUrl;
    }
    
    // Only include fields that are not null (i.e., fields being updated)
    updateData['displayName'] = profile.displayName;
    if (profile.userName != null) updateData['userName'] = profile.userName;
    if (profile.gender != null) updateData['gender'] = profile.gender;
    if (profile.dateOfBirth != null) updateData['dateOfBirth'] = Timestamp.fromDate(profile.dateOfBirth!);
    if (profile.bio != null) updateData['bio'] = profile.bio;
    if (profile.address != null) updateData['address'] = profile.address;
    if (profile.instagramLink != null) updateData['instagramLink'] = profile.instagramLink;
    if (profile.youtubeLink != null) updateData['youtubeLink'] = profile.youtubeLink;
    if (profile.whatsappLink != null) updateData['whatsappLink'] = profile.whatsappLink;
    
    // Always update the updatedAt timestamp
    updateData['updatedAt'] = Timestamp.now();
    
    // Update only the specified fields in Firebase
    await firestore.collection(usersCollection).doc(profile.uid).update(updateData);
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await firestore
          .collection(usersCollection)
          .where('userName', isEqualTo: username)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      // If there's an error, assume username is not available for safety
      return false;
    }
  }
}
