


import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_extra_mile_new/core/constants/firebase_constants.dart';
import 'package:go_extra_mile_new/core/service/firebase_storage_service.dart';
import 'package:go_extra_mile_new/features/profile/data/model/profile_model.dart';
import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileDataSource {
  Future<ProfileEntity?> getProfile(String uid);
  Future<String?> getUserProfileImage(String uid);
  Future<void> updateProfile(ProfileEntity profile, File? profilePhotoImageFile);
  Future<bool> isUsernameAvailable(String username);
}

class ProfileDataSourceImpl implements ProfileDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorageService firebaseStorageService;

  ProfileDataSourceImpl(this.firestore, this.firebaseStorageService);

  @override
  Future<ProfileEntity?> getProfile(String uid) async {
    final doc = await firestore.collection(usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return ProfileModel.fromMap(doc.data()!);
  }

  @override
  Future<String?> getUserProfileImage(String uid) async {
    final doc = await firestore.collection(usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return doc.data()?['photoUrl'];
  }

  @override
  Future<void> updateProfile(ProfileEntity profile, File? profilePhotoImageFile) async {
    // This method handles profile updates including clearing optional fields
    // Null values for optional fields (bio, instagram, youtube, whatsapp) will clear them in the database
    
    // Create a map with the fields to be updated
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
    
    // Always include required fields
    updateData['displayName'] = profile.displayName;
    
    // Include optional fields - handle null values to allow clearing fields
    updateData['userName'] = profile.userName;
    updateData['gender'] = profile.gender;
    updateData['dateOfBirth'] = profile.dateOfBirth != null ? Timestamp.fromDate(profile.dateOfBirth!) : null;
    updateData['bio'] = profile.bio;
    updateData['address'] = profile.address;
    updateData['instagramLink'] = profile.instagramLink;
    updateData['youtubeLink'] = profile.youtubeLink;
    updateData['whatsappLink'] = profile.whatsappLink;
    updateData['showInstagram'] = profile.showInstagram;
    updateData['showYoutube'] = profile.showYoutube;
    updateData['showWhatsapp'] = profile.showWhatsapp;
    
    // Handle boolean fields - include them even if null to allow clearing
    updateData['privateProfile'] = profile.privateProfile;
    
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
