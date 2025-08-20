import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Picks multiple images from the gallery
  /// Returns a list of [File] objects, or null if the operation was cancelled
  /// Throws an exception if there's an error during the process
  static Future<List<File>?> pickMultiImage({
    int? imageQuality = 80,
    double? maxSizeInMB = 5,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
      );
      
      if (images.isEmpty) return null;

      final List<File> imageFiles = [];
      
      // Check file sizes and convert to File objects
      for (final image in images) {
        final File imageFile = File(image.path);
        
        if (maxSizeInMB != null) {
          final int fileSizeInBytes = await imageFile.length();
          final double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

          if (fileSizeInMB > maxSizeInMB) {
            throw Exception('Each image size must be less than ${maxSizeInMB}MB');
          }
        }
        
        imageFiles.add(imageFile);
      }

      return imageFiles;
    } catch (e) {
      throw Exception('Error picking images: ${e.toString()}');
    }
  }

  /// Picks and crops an image from the specified source
  /// Returns a [File] object of the cropped image, or null if the operation was cancelled
  /// Throws an exception if there's an error during the process
  static Future<File?> pickAndCropImage({
    required BuildContext context,
    double? maxSizeInMB = 5,
    bool forceCropAspectRatio = true,
    double ratioX = 1,
    double ratioY = 1,
    CropStyle cropStyle = CropStyle.circle,
    int? imageQuality = 80,
  }) async {
    // Show bottom sheet to select image source
    final ImageSource? source = await _showImageSourceDialog(context);
    if (source == null) return null;
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );
      
      if (image == null) return null;

      // Check file size
      final File imageFile = File(image.path);
      if (maxSizeInMB != null) {
        final int fileSizeInBytes = await imageFile.length();
        final double fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

        if (fileSizeInMB > maxSizeInMB) {
          throw Exception('Image size must be less than ${maxSizeInMB}MB');
        }
      }

      // Crop image
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: forceCropAspectRatio 
            ? CropAspectRatio(ratioX: ratioX, ratioY: ratioY)
            : null,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor:  context.mounted ? Theme.of(context).primaryColor : Colors.blue, // Use app primary color
            toolbarWidgetColor: Colors.white,
            statusBarColor: context.mounted ? Theme.of(context).primaryColor : Colors.blue, // Ensure status bar is visible and safe
            backgroundColor: Colors.black, // Cropp   er background
            activeControlsWidgetColor: context.mounted ? Theme.of(context).primaryColor : Colors.blue,
            cropFrameColor: context.mounted ? Theme.of(context).primaryColor : Colors.blue,
            cropGridColor: Colors.white24,
            cropStyle: cropStyle,
            dimmedLayerColor: Colors.black54,
            showCropGrid: true,
            lockAspectRatio: forceCropAspectRatio,
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.square,
            cropFrameStrokeWidth: 2,
            cropGridRowCount: 3,
            cropGridColumnCount: 3,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: forceCropAspectRatio,
            resetAspectRatioEnabled: !forceCropAspectRatio,
            aspectRatioPickerButtonHidden: forceCropAspectRatio,
            rotateButtonsHidden: false,
            resetButtonHidden: false,
            minimumAspectRatio: 1.0,
            rectX: ratioX,
            rectY: ratioY,
            cropStyle: cropStyle,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            // iOS cropper is presented modally and respects safe area by default
          ),
        ],
      );

      if (croppedFile == null) return null;

      // Check cropped file size
      if (maxSizeInMB != null) {
        final File croppedImageFile = File(croppedFile.path);
        final int croppedFileSizeInBytes = await croppedImageFile.length();
        final double croppedFileSizeInMB = croppedFileSizeInBytes / (1024 * 1024);

        if (croppedFileSizeInMB > maxSizeInMB) {
          throw Exception('Cropped image size must be less than ${maxSizeInMB}MB. Please try again with a smaller image or crop area.');
        }
      }

      return File(croppedFile.path);
    } catch (e) {
      throw Exception('Error picking/cropping image: ${e.toString()}');
    }
  }

  /// Shows a modern dialog to select image source
  static Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildOptionTile(
                        context,
                        icon: Icons.camera_alt_rounded,
                        title: 'Take Photo',
                        subtitle: 'Use camera to capture a new photo',
                        onTap: () => Navigator.pop(context, ImageSource.camera),
                      ),
                      const SizedBox(height: 12),
                      _buildOptionTile(
                        context,
                        icon: Icons.photo_library_rounded,
                        title: 'Choose from Gallery',
                        subtitle: 'Select an existing photo from your gallery',
                        onTap: () => Navigator.pop(context, ImageSource.gallery),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Cancel button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1)  ,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 