import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'dart:io';

class CircularImage extends StatelessWidget {
  final VoidCallback? onTap;
  final String? imageUrl; // Changed to nullable
  final String? heroTag;
  final double? width;
  final double? height;
  const CircularImage({
    super.key,
    this.imageUrl, // Made optional
    this.heroTag,
    this.width = 120,
    this.height = 120,
    this.onTap,
  });

  Widget _buildImage() {
    // Check if imageUrl is null
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }
    
    // Check if the imageUrl is a file path
    if (imageUrl!.startsWith('/') || imageUrl!.contains('\\') || imageUrl!.startsWith('file://')) {
      try {
        return Image.file(
          File(imageUrl!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
        );
      } catch (e) {
        return const Icon(Icons.person);
      }
    }
    
    // Handle network images
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => const Icon(Icons.person),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
        child: heroTag != null
            ? Hero(
                tag: heroTag!,
                child: _buildCircularImage(context),
              )
            : _buildCircularImage(context),
      ),
    );
  }

  Widget _buildCircularImage(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(3),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }
}
