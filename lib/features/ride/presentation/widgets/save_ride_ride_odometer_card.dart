import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/odometer_entity.dart';

class OdometerCard extends StatelessWidget {
  final dynamic beforeImage; // File or String (URL)
  final DateTime beforeCaptureTime;
  final dynamic afterImage; // File or String (URL)
  final DateTime afterCaptureTime;
  final OdometerVerificationStatus? verificationStatus;

  const OdometerCard({
    super.key,
    required this.beforeImage,
    required this.beforeCaptureTime,
    required this.afterImage,
    required this.afterCaptureTime,
    this.verificationStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Odometer Readings', // fixed title
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (verificationStatus != null) _buildVerificationBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOdometerItem('Before Ride', beforeImage, beforeCaptureTime),
              _buildOdometerItem('After Ride', afterImage, afterCaptureTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOdometerItem(String title, dynamic image, DateTime captureTime) {
    Widget imageWidget;

    if (image is File) {
      imageWidget = Image.file(
        image,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (image is String && image.isNotEmpty) {
      // Check if it's a local file path or a network URL
      if (image.startsWith('http://') || image.startsWith('https://')) {
        // It's a network URL
        imageWidget = CachedNetworkImage(
          imageUrl: image,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.error_outline),
          ),
        );
      } else {
        // It's a local file path
        final file = File(image);
        imageWidget = Image.file(
          file,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 100,
              height: 100,
              color: Colors.grey.shade200,
              child: const Icon(Icons.error_outline),
            );
          },
        );
      }
    } else {
      imageWidget = Container(
        width: 100,
        height: 100,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported),
      );
    }

    // Wrap image with border
    imageWidget = Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade500, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      ),
    );

    return Column(
      children: [
        imageWidget,
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(captureTime),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildVerificationBadge() {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    switch (verificationStatus) {
      case OdometerVerificationStatus.verified:
        badgeColor = Colors.green;
        badgeIcon = Icons.check_circle;
        badgeText = 'Verified';
        break;
      case OdometerVerificationStatus.rejected:
        badgeColor = Colors.red;
        badgeIcon = Icons.cancel;
        badgeText = 'Rejected';
        break;
      case OdometerVerificationStatus.pending:
      default:
        badgeColor = Colors.orange;
        badgeIcon = Icons.pending;
        badgeText = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
