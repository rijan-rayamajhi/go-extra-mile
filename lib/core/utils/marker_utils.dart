import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MarkerUtils {
  /// Creates a circular marker from an image URL.
  ///
  /// [imageUrl] is the URL of the image to use as the marker.
  /// [size] is the size of the marker in pixels.
  ///
  /// Returns a [BitmapDescriptor] that can be used as a marker in Google Maps.
  ///
  /// [borderWidth] and [borderColor] customize the circular border drawn on top of the image.
  static Future<BitmapDescriptor> circularMarker(
    String imageUrl, {
    int size = 120,
    double borderWidth = 4.0,
    Color borderColor = Colors.black,
  }) async {
    // Fallback early if the URL is empty or blank
    if (imageUrl.trim().isEmpty) {
      return await _createMyLocationFallback(
        size: size,
        borderWidth: borderWidth,
        borderColor: borderColor,
      );
    }

    try {
      final http.Response response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return await _createMyLocationFallback(
          size: size,
          borderWidth: borderWidth,
          borderColor: borderColor,
        );
      }

      final Uint8List imageData = response.bodyBytes;

      // Decode image
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: size,
        targetHeight: size,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Draw circle on canvas
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint()..isAntiAlias = true;

      final double radius = size / 2;
      final Rect rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
      final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

      canvas.clipRRect(rRect);
      paint.filterQuality = FilterQuality.high;
      canvas.drawImage(image, Offset.zero, paint);

      // Draw inner black border (fully inside the circle to avoid clipping)
      if (borderWidth > 0) {
        final Paint borderPaint = Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = borderColor;
        canvas.drawCircle(
          Offset(radius, radius),
          radius - (borderWidth / 2),
          borderPaint,
        );
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(size, size);
      final ByteData? byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        return await _createMyLocationFallback(
          size: size,
          borderWidth: borderWidth,
          borderColor: borderColor,
        );
      }

      return BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    } catch (_) {
      // Network, decoding, or drawing failed; return a safe default marker.
      return await _createMyLocationFallback(
        size: size,
        borderWidth: borderWidth,
        borderColor: borderColor,
      );
    }
  }

  static Future<BitmapDescriptor> _createMyLocationFallback({
    required int size,
    required double borderWidth,
    required Color borderColor,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..isAntiAlias = true;

    final double radius = size / 2;
    final Offset center = Offset(radius, radius);

    // Background fill
    paint
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    // Outer border
    if (borderWidth > 0) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor;
      canvas.drawCircle(center, radius - (borderWidth / 2), paint);
    }

    // My-location style target
    final Color accent = Colors.blueAccent;

    // Outer ring
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.08
      ..color = accent;
    final double outerRingRadius = radius * 0.55;
    canvas.drawCircle(center, outerRingRadius, paint);

    // Crosshair ticks
    final double tickLength = radius * 0.18;
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06
      ..color = accent;
    // Top
    canvas.drawLine(
      Offset(center.dx, center.dy - outerRingRadius - tickLength / 2),
      Offset(center.dx, center.dy - outerRingRadius + tickLength / 2),
      paint,
    );
    // Bottom
    canvas.drawLine(
      Offset(center.dx, center.dy + outerRingRadius - tickLength / 2),
      Offset(center.dx, center.dy + outerRingRadius + tickLength / 2),
      paint,
    );
    // Left
    canvas.drawLine(
      Offset(center.dx - outerRingRadius - tickLength / 2, center.dy),
      Offset(center.dx - outerRingRadius + tickLength / 2, center.dy),
      paint,
    );
    // Right
    canvas.drawLine(
      Offset(center.dx + outerRingRadius - tickLength / 2, center.dy),
      Offset(center.dx + outerRingRadius + tickLength / 2, center.dy),
      paint,
    );

    // Center dot
    paint
      ..style = PaintingStyle.fill
      ..color = accent;
    canvas.drawCircle(center, radius * 0.1, paint);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(size, size);
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// Creates a rectangular marker from an image URL.
  ///
  /// [imageUrl] → image to load for the marker.
  /// [width], [height] → dimensions of the rectangle in pixels.
  /// [borderWidth], [borderColor] → optional border.
  static Future<BitmapDescriptor> rectangularMarker(
    String imageUrl, {
    int width = 140,
    int height = 100,
    double borderWidth = 4.0,
    Color borderColor = Colors.black,
    double borderRadius = 12.0, // for rounded rectangle look
  }) async {
    if (imageUrl.trim().isEmpty) {
      return await _createFallback(
        width: width,
        height: height,
        borderWidth: borderWidth,
        borderColor: borderColor,
        borderRadius: borderRadius,
      );
    }

    try {
      final http.Response response = await http
          .get(Uri.parse(imageUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return await _createFallback(
          width: width,
          height: height,
          borderWidth: borderWidth,
          borderColor: borderColor,
          borderRadius: borderRadius,
        );
      }

      final Uint8List imageData = response.bodyBytes;

      // Decode image to fit target size
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageData,
        targetWidth: width,
        targetHeight: height,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint paint = Paint()..isAntiAlias = true;

      final Rect rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
      final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

      // Clip into rounded rect
      canvas.clipRRect(rRect);

      // Draw image
      paint.filterQuality = FilterQuality.high;
      canvas.drawImage(image, Offset.zero, paint);

      // Draw border
      if (borderWidth > 0) {
        final Paint borderPaint = Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth
          ..color = borderColor;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rect.deflate(borderWidth / 2),
            Radius.circular(borderRadius),
          ),
          borderPaint,
        );
      }

      final ui.Picture picture = recorder.endRecording();
      final ui.Image finalImage = await picture.toImage(width, height);
      final ByteData? byteData =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
    } catch (_) {
      return await _createFallback(
        width: width,
        height: height,
        borderWidth: borderWidth,
        borderColor: borderColor,
        borderRadius: borderRadius,
      );
    }
  }
  
  /// Simple fallback if image fails
  static Future<BitmapDescriptor> _createFallback({
    required int width,
    required int height,
    required double borderWidth,
    required Color borderColor,
    required double borderRadius,
  }) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Paint paint = Paint()..isAntiAlias = true;

    final Rect rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Background
    paint
      ..style = PaintingStyle.fill
      ..color = Colors.grey.shade300;
    canvas.drawRRect(rRect, paint);

    // Border
    if (borderWidth > 0) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(borderWidth / 2),
          Radius.circular(borderRadius),
        ),
        paint,
      );
    }

    // Draw "X" fallback symbol
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = Colors.red;
    canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
    canvas.drawLine(rect.bottomLeft, rect.topRight, paint);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image finalImage = await picture.toImage(width, height);
    final ByteData? byteData =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}


