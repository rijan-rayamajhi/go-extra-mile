import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? borderColor;
  final IconData? icon;
  final String? iconImage;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.borderColor,
    this.icon,
    this.iconImage,
  });

  void _handlePress() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    }
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        side: BorderSide(
          color: borderColor ?? Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        foregroundColor: Theme.of(context).colorScheme.primary,
        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: context.fontSize(baseXLargeFontSize),
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            context.borderRadius(baseButtonRadius),
          ),
        ),
        minimumSize: Size(
          baseButtonWidth,
          context.buttonHeight(baseButtonHeight),
        ),
      ),
      onPressed: isLoading ? null : _handlePress,
      child: isLoading
          ? CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
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
                SizedBox(width: context.baseSpacing(baseSmallSpacing)),
                Text(text),
              ],
            )
          : icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: context.iconSize(baseMediumIconSize)),
                SizedBox(width: context.baseSpacing(baseSmallSpacing)),
                Text(text),
              ],
            )
          : Text(text),
    );
  }
}
