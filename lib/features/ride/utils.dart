import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

double haversine(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000.0;
  final dLat = (lat2 - lat1) * pi / 180;
  final dLon = (lon2 - lon1) * pi / 180;
  final a =
      sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) *
          cos(lat2 * pi / 180) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return R * c;
}

String formatDuration(Duration d) {
  final hours = d.inHours.toString().padLeft(2, '0');
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "$hours:$minutes:$seconds";
}

List<LatLng> filteredPoints(List<LatLng> points, {double minDistance = 10}) {
  if (points.isEmpty) return [];
  if (points.length == 1) return points;
  
  // Step 1: Remove points that are too close together
  List<LatLng> distanceFiltered = [points.first];
  for (var point in points.skip(1)) {
    final last = distanceFiltered.last;
    final distance = haversine(
      last.latitude,
      last.longitude,
      point.latitude,
      point.longitude,
    );
    if (distance >= minDistance) {
      distanceFiltered.add(point);
    }
  }
  
  if (distanceFiltered.length < 3) return distanceFiltered;
  
  // Step 2: Remove zigzag points using angle analysis
  List<LatLng> angleFiltered = [distanceFiltered.first];
  
  for (int i = 1; i < distanceFiltered.length - 1; i++) {
    final prev = distanceFiltered[i - 1];
    final current = distanceFiltered[i];
    final next = distanceFiltered[i + 1];
    
    // Calculate angle between three consecutive points
    final angle = _calculateAngle(prev, current, next);
    
    // Only keep points that represent significant direction changes
    // Skip points with very sharp angles (likely GPS noise)
    if (angle > 20 && angle < 160) {
      angleFiltered.add(current);
    }
  }
  
  // Always include the last point
  angleFiltered.add(distanceFiltered.last);
  
  // Step 3: Apply smoothing to reduce minor variations
  return _smoothPoints(angleFiltered);
}

// Calculate angle between three points in degrees
double _calculateAngle(LatLng p1, LatLng p2, LatLng p3) {
  final bearing1 = _calculateBearing(p2, p1);
  final bearing2 = _calculateBearing(p2, p3);
  
  double angle = (bearing2 - bearing1).abs();
  if (angle > 180) {
    angle = 360 - angle;
  }
  return angle;
}

// Calculate bearing between two points
double _calculateBearing(LatLng start, LatLng end) {
  final startLat = start.latitude * pi / 180;
  final startLng = start.longitude * pi / 180;
  final endLat = end.latitude * pi / 180;
  final endLng = end.longitude * pi / 180;
  
  final dLng = endLng - startLng;
  
  final y = sin(dLng) * cos(endLat);
  final x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);
  
  final bearing = atan2(y, x);
  
  return (bearing * 180 / pi + 360) % 360;
}

// Apply smoothing using moving average
List<LatLng> _smoothPoints(List<LatLng> points) {
  if (points.length < 3) return points;
  
  List<LatLng> smoothed = [points.first];
  
  for (int i = 1; i < points.length - 1; i++) {
    final prev = points[i - 1];
    final current = points[i];
    final next = points[i + 1];
    
    // Apply weighted average (current point gets more weight)
    final smoothedLat = (prev.latitude * 0.2 + current.latitude * 0.6 + next.latitude * 0.2);
    final smoothedLng = (prev.longitude * 0.2 + current.longitude * 0.6 + next.longitude * 0.2);
    
    smoothed.add(LatLng(smoothedLat, smoothedLng));
  }
  
  smoothed.add(points.last);
  return smoothed;
}

/// Converts a File image into a BitmapDescriptor with rounded corners and border
Future<BitmapDescriptor> bitmapFromFileWithBorder(
  File file, {
  int width = 120,
  int height = 120,
  double borderRadius = 16,
  double borderWidth = 4,
  Color borderColor = Colors.black,
}) async {
  final imageBytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(
    imageBytes,
    targetWidth: width,
    targetHeight: height,
  );
  final frame = await codec.getNextFrame();
  final ui.Image image = frame.image;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  final rect = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
  final paint = Paint();

  // Draw image with rounded corners
  final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
  canvas.clipRRect(rrect);
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    rect,
    paint,
  );

  // Draw border
  final borderPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = borderWidth;
  canvas.drawRRect(rrect, borderPaint);

  final picture = recorder.endRecording();
  final img = await picture.toImage(width, height);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

  return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
}
