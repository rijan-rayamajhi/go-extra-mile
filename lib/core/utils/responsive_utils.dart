import 'package:flutter/material.dart';

/// Responsive utility class for handling screen dimensions and responsive design
class ResponsiveUtils {
  /// Get screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get responsive width based on screen width percentage
  static double width(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  /// Get responsive height based on screen height percentage
  static double height(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  /// Get responsive font size based on screen width
  static double fontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Base font size scaling factor for different screen sizes
    if (screenWidth < 360) {
      return baseFontSize * 0.85; // Small screens
    } else if (screenWidth < 414) {
      return baseFontSize * 0.95; // Medium screens
    } else if (screenWidth < 768) {
      return baseFontSize; // Large phones
    } else {
      return baseFontSize * 1.1; // Tablets
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets padding(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.8 : screenWidth < 414 ? 0.9 : 1.0;

    if (all != null) {
      return EdgeInsets.all(all * scaleFactor);
    }

    return EdgeInsets.only(
      top: (top ?? vertical ?? 0) * scaleFactor,
      bottom: (bottom ?? vertical ?? 0) * scaleFactor,
      left: (left ?? horizontal ?? 0) * scaleFactor,
      right: (right ?? horizontal ?? 0) * scaleFactor,
    );
  }

  /// Get responsive margin based on screen size
  static EdgeInsets margin(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.8 : screenWidth < 414 ? 0.9 : 1.0;

    if (all != null) {
      return EdgeInsets.all(all * scaleFactor);
    }

    return EdgeInsets.only(
      top: (top ?? vertical ?? 0) * scaleFactor,
      bottom: (bottom ?? vertical ?? 0) * scaleFactor,
      left: (left ?? horizontal ?? 0) * scaleFactor,
      right: (right ?? horizontal ?? 0) * scaleFactor,
    );
  }

  /// Get responsive border radius based on screen size
  static double borderRadius(BuildContext context, double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.8 : screenWidth < 414 ? 0.9 : 1.0;
    return baseRadius * scaleFactor;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  /// Get responsive spacing based on screen size
  static double spacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.8 : screenWidth < 414 ? 0.9 : 1.0;
    return baseSpacing * scaleFactor;
  }

  /// Get responsive icon size based on screen size
  static double iconSize(BuildContext context, double baseIconSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.8 : screenWidth < 414 ? 0.9 : 1.0;
    return baseIconSize * scaleFactor;
  }

  /// Get responsive button height based on screen size
  static double buttonHeight(BuildContext context, double baseHeight) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.9 : screenWidth < 414 ? 0.95 : 1.0;
    return baseHeight * scaleFactor;
  }

  /// Get responsive container dimensions
  static Size containerSize(BuildContext context, {
    required double widthPercentage,
    required double heightPercentage,
  }) {
    return Size(
      width(context, widthPercentage),
      height(context, heightPercentage),
    );
  }

  /// Get responsive image dimensions maintaining aspect ratio
  static Size imageSize(BuildContext context, {
    required double maxWidthPercentage,
    required double aspectRatio,
  }) {
    final maxWidth = width(context, maxWidthPercentage);
    final calculatedHeight = maxWidth / aspectRatio;
    return Size(maxWidth, calculatedHeight);
  }
}

/// Extension methods for easier responsive usage
extension ResponsiveExtension on BuildContext {
  /// Get screen width
  double get screenWidth => ResponsiveUtils.screenWidth(this);

  /// Get screen height
  double get screenHeight => ResponsiveUtils.screenHeight(this);

  /// Get responsive width
  double width(double percentage) => ResponsiveUtils.width(this, percentage);

  /// Get responsive height
  double height(double percentage) => ResponsiveUtils.height(this, percentage);

  /// Get responsive font size
  double fontSize(double baseFontSize) => ResponsiveUtils.fontSize(this, baseFontSize);

  /// Get responsive padding
  EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) => ResponsiveUtils.padding(this,
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );

  /// Get responsive margin
  EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) => ResponsiveUtils.margin(this,
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );

  /// Get responsive border radius
  double borderRadius(double baseRadius) => ResponsiveUtils.borderRadius(this, baseRadius);

  /// Check if tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);

  /// Check if mobile
  bool get isMobile => ResponsiveUtils.isMobile(this);

  /// Get responsive spacing
  double spacing(double baseSpacing) => ResponsiveUtils.spacing(this, baseSpacing);

  /// Get responsive icon size
  double iconSize(double baseIconSize) => ResponsiveUtils.iconSize(this, baseIconSize);

  /// Get responsive button height
  double buttonHeight(double baseHeight) => ResponsiveUtils.buttonHeight(this, baseHeight);
}
