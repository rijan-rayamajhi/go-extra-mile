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

List<LatLng> filteredPoints(List<LatLng> points, {double minDistance = 100}) {
  if (points.isEmpty) return [];
  List<LatLng> filtered = [points.first];

  for (var point in points) {
    final last = filtered.last;
    final distance = haversine(
      last.latitude,
      last.longitude,
      point.latitude,
      point.longitude,
    );
    if (distance >= minDistance) {
      filtered.add(point);
    }
  }
  return filtered;
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
