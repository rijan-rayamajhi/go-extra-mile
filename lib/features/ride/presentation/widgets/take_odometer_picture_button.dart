import 'package:flutter/material.dart';

class TakeOdometerPictureButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String? subtitle;
  final String? title;

  const TakeOdometerPictureButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.subtitle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLoading 
                  ? Colors.grey[300]
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: isLoading 
                    ? Colors.grey[400]!
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: isLoading
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  )
                : Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            title ?? 'Capture',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isLoading 
                  ? Colors.grey[600]
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10,
                color: isLoading 
                    ? Colors.grey[500]
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const SizedBox(height: 2),
            Text(
              '(Earn upto 10x rewards)',
              style: TextStyle(
                fontSize: 10,
                color: isLoading 
                    ? Colors.grey[500]
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 