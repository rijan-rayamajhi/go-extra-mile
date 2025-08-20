import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/map_circular_button.dart';
import 'package:go_extra_mile_new/core/utils/image_picker_utils.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/core/service/firebase_storage_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';


class RideCaptureMemoriesButton extends StatelessWidget {
  final Function(String downloadUrl)? onMemoryCaptured;
  
  const RideCaptureMemoriesButton({
    super.key,
    this.onMemoryCaptured,
  });

  Future<void> _handleCaptureMemory(BuildContext context) async {
    try {
      // Capture a memory photo using camera or gallery
      final File? capturedImage = await ImagePickerUtils.pickAndCropImage(
        context: context,
        maxSizeInMB: 5, // Limit image size to 5MB
        forceCropAspectRatio: true,
        ratioX: 1,
        ratioY: 1, // Square aspect ratio for memories
        cropStyle: CropStyle.rectangle, // Use rectangle for ride memories
        imageQuality: 85, // Good quality for memories
      );

      if (capturedImage != null) {
        // Show loading message
        if (context.mounted) {
          AppSnackBar.info(
            context,
            'Uploading memory...',
          );
        }

        try {
          // Upload image to Firebase Storage
          final FirebaseStorageService storageService = FirebaseStorageService();
          
          // Generate unique path for the memory image
          final String fileName = 'ride_memory_${DateTime.now().millisecondsSinceEpoch}.jpg';
          final String storagePath = 'ride_memories/$fileName';
          
          // Upload the file
          final String downloadUrl = await storageService.uploadFile(
            file: capturedImage,
            path: storagePath,
            metadata: SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {
                'captured_at': DateTime.now().toIso8601String(),
                'file_size': '${await capturedImage.length()}',
                'aspect_ratio': '1:1',
              },
            ),
          );

          // Successfully uploaded
          if (context.mounted) {
            AppSnackBar.success(
              context,
              'Memory captured and uploaded successfully!',
            );
          }

          // Return the download URL through callback
          onMemoryCaptured?.call(downloadUrl);

          // TODO: Add logic to:
          // 1. Save image metadata to local storage
          // 2. Add to ride memories collection in Firestore
          // 3. Update ride state with new memory
          // 4. Store the download URL for future use
          
          print('Memory uploaded successfully! Download URL: $downloadUrl');
          print('Storage path: $storagePath');
          
        } catch (uploadError) {
          // Handle upload errors
          if (context.mounted) {
            AppSnackBar.error(
              context,
              'Failed to upload memory: ${uploadError.toString()}',
            );
          }
          print('Upload error: $uploadError');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(
          context,
          'Failed to capture memory: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapCircularButton(
      icon: Icons.photo_camera,
      onPressed: () => _handleCaptureMemory(context),
    );
  }
}
