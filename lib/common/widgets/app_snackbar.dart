import 'package:flutter/material.dart';

enum AppSnackBarType { success, error, info, warning }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    double topOffset = 250,
  }) {
    final theme = Theme.of(context);

    // Pick background color and icon by type
    final Color backgroundColor;
    final IconData icon;
    switch (type) {
      case AppSnackBarType.success:
        backgroundColor = theme.colorScheme.primary;
        icon = Icons.check_circle_rounded;
        break;
      case AppSnackBarType.error:
        backgroundColor = theme.colorScheme.error;
        icon = Icons.error_rounded;
        break;
      case AppSnackBarType.warning:
        backgroundColor = theme.colorScheme.tertiary;
        icon = Icons.warning_rounded;
        break;
      case AppSnackBarType.info:
        backgroundColor = theme.colorScheme.primary;
        icon = Icons.info_rounded;
        break;
    }

    final mediaQuery = MediaQuery.of(context);
    final double bottomMargin = (mediaQuery.size.height - topOffset).clamp(0, mediaQuery.size.height);

    final snackBar = SnackBar(
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.onPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(left: 20, right: 20, bottom: bottomMargin),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      duration: duration,
      action: (actionLabel != null && onAction != null)
          ? SnackBarAction(
              label: actionLabel,
              textColor: theme.colorScheme.onPrimary,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message, {double topOffset = 200}) =>
      show(context, message: message, type: AppSnackBarType.success, topOffset: topOffset);

  static void error(BuildContext context, String message, {double topOffset = 200}) =>
      show(context, message: message, type: AppSnackBarType.error, topOffset: topOffset);

  static void info(BuildContext context, String message, {double topOffset = 200}) =>
      show(context, message: message, type: AppSnackBarType.info, topOffset: topOffset);

  static void warning(BuildContext context, String message, {double topOffset = 200}) =>
      show(context, message: message, type: AppSnackBarType.warning, topOffset: topOffset);

  static void showSnackBar(BuildContext context, String s) {}
}