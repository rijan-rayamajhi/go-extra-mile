import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage;
import 'package:flutter/material.dart';
import 'dart:io';

class RectImage extends StatelessWidget {
  final VoidCallback? onTap;
  final String imageUrl;
  final String? heroTag;

  const RectImage({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.onTap,
  });

  Widget _buildImage() {
    // Check if the imageUrl is a file path
    if (imageUrl.startsWith('/') ||
        imageUrl.contains('\\') ||
        imageUrl.startsWith('file://')) {
      try {
        return Image.file(
          File(imageUrl),
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.person),
        );
      } catch (e) {
        return const Icon(Icons.person);
      }
    }

    // Handle network images
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.fill,
      errorWidget: (context, url, error) => const Icon(Icons.person),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 10, // 🔥 Ensures 16:9 ratio
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: heroTag != null
              ? Hero(
                  tag: heroTag!,
                  child: _buildImage(),
                )
              : _buildImage(),
        ),
      ),
    );
  }
}
