import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';

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
          fontSize: context.fontSize(baseXLargeFontSize),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.borderRadius(baseButtonRadius)),
        ),
        minimumSize: Size(buttonWidth, context.buttonHeight(baseButtonHeight)),
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
                  width: context.iconSize(baseMediumIconSize),
                  height: context.iconSize(baseMediumIconSize),
                ),
                SizedBox(width: context.spacing(baseSmallSpacing)),
                Text(text),
              ],
            )
          : icon != null 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: context.iconSize(baseMediumIconSize)),
                  SizedBox(width: context.spacing(baseSmallSpacing)),
                  Text(text),
                ],
              )
            : Text(text),
    );
  }
}