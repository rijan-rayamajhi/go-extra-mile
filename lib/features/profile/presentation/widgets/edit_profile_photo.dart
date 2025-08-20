import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';

class EditProfilePhotoSection extends StatelessWidget {
  final String imageUrl;
  final bool isLoading;
  final VoidCallback? onTap;
  final String heroTag;

  const EditProfilePhotoSection({
    super.key,
    required this.imageUrl,
    required this.isLoading,
    required this.heroTag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircularImage(
          imageUrl: imageUrl,
          heroTag: heroTag,
          onTap: onTap,
        ),
        GestureDetector(
          onTap: isLoading ? null : onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 6,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Icon(Icons.camera_alt, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}

