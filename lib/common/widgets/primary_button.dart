import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final IconData? icon;
  final String? iconImage;

  const PrimaryButton({
    super.key, 
    required this.text, 
    required this.onPressed, 
    this.isLoading = false, 
    this.backgroundColor,
    this.icon, 
    this.iconImage,
  });

  void _handlePress() {
    // Provide haptic feedback for iOS users
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    }
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        minimumSize: const Size(buttonWidth,buttonHeight),
      ),
      onPressed: _handlePress,
      child: isLoading 
        ?  CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onPrimary,
            strokeWidth: 2, 
            
        ) 
        : iconImage != null 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  iconImage!,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 16),
                Text(text),
              ],
            )
          : icon != null 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 16),
                  Text(text),
                ],
              )
            : Text(text),
    );
  }
}