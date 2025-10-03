import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';

class RideMemoryWidget extends StatefulWidget {
  final GeoPoint startCoordinate;
  final GeoPoint endCoordinate;
  final List<RideMemoryEntity> rideMemories;

  const RideMemoryWidget({
    super.key,
    required this.startCoordinate,
    required this.endCoordinate,
    required this.rideMemories,
  });

  @override
  State<RideMemoryWidget> createState() => _RideMemoryWidgetState();
}

class _RideMemoryWidgetState extends State<RideMemoryWidget> {
  final ScrollController _controller = ScrollController();
  double _progress = 0.0;
  String? startAddress;
  String? endAddress;
  final Map<int, String> _memoryAddresses = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateProgress);
    _resolveStartEndAddresses();
    _resolveMemoryAddresses();
  }

  Future<void> _resolveStartEndAddresses() async {
    try {
      final startPlacemarks = await placemarkFromCoordinates(
        widget.startCoordinate.latitude,
        widget.startCoordinate.longitude,
      );
      final endPlacemarks = await placemarkFromCoordinates(
        widget.endCoordinate.latitude,
        widget.endCoordinate.longitude,
      );
      setState(() {
        startAddress = _formatPlacemark(startPlacemarks.first);
        endAddress = _formatPlacemark(endPlacemarks.first);
      });
    } catch (_) {
      setState(() {
        startAddress = 'Unknown';
        endAddress = 'Unknown';
      });
    }
  }

  void _resolveMemoryAddresses() {
    for (int i = 0; i < widget.rideMemories.length; i++) {
      final coords = widget.rideMemories[i].capturedCoordinates;
      if (coords != null) _getMemoryAddress(i, coords);
    }
  }

  Future<void> _getMemoryAddress(int index, GeoPoint coords) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        coords.latitude,
        coords.longitude,
      );
      setState(
        () => _memoryAddresses[index] = _formatPlacemark(placemarks.first),
      );
    } catch (_) {
      setState(() => _memoryAddresses[index] = 'Unknown');
    }
  }

  String _formatPlacemark(Placemark placemark) =>
      '${placemark.locality ?? ''}, ${placemark.country ?? ''}';

  void _updateProgress() {
    if (!_controller.hasClients || !_controller.position.hasContentDimensions) {
      return;
    }
    final maxScroll = _controller.position.maxScrollExtent;
    setState(() {
      _progress = (_controller.offset / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ride Memory',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (startAddress != null && endAddress != null)
            Stack(
              children: [
                SingleChildScrollView(
                  controller: _controller,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 24),
                      _buildMilestone(startAddress!),
                      for (int i = 0; i < widget.rideMemories.length; i++) ...[
                        _roadSegment(),
                        _memoryPoint(widget.rideMemories[i], i),
                      ],
                      _roadSegment(),
                      _buildMilestone(endAddress!),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _fadeEdge(Alignment.centerLeft),
                        _fadeEdge(Alignment.centerRight),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 8),
          SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fadeEdge(Alignment alignment) => Container(
    width: 40,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: alignment,
        end: alignment == Alignment.centerLeft
            ? Alignment.centerRight
            : Alignment.centerLeft,
        colors: [Colors.white, Colors.white.withOpacity(0.0)],
      ),
    ),
  );

  Widget _buildMilestone(String label) => Column(
    children: [
      Image.asset('assets/icons/road_milestone.png', width: 60, height: 60),
      const SizedBox(height: 4),
      SizedBox(
        width: 80,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    ],
  );

  Widget _memoryPoint(RideMemoryEntity memory, int index) {
    Widget imageWidget;
    final filePath = memory.imageUrl;

    if (filePath != null && File(filePath).existsSync()) {
      imageWidget = Image.file(
        File(filePath),
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      );
    } else if (filePath != null && filePath.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: filePath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.error_outline),
        ),
      );
    } else {
      imageWidget = Container(
        width: 70,
        height: 70,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_not_supported),
      );
    }

    final address = _memoryAddresses[index] ?? 'Loading...';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageWidget,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: Text(
            address,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _roadSegment() => SizedBox(
    width: 140,
    height: 100,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomPaint(painter: DottedRoadPainter()),
    ),
  );
}

class DottedRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const double dashWidth = 6;
    const double dashSpace = 4;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(
        size.width * 0.25,
        -size.height * 0.8,
        size.width * 0.75,
        size.height * 1.3,
        size.width,
        size.height * 0.5,
      );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            distance + dashWidth,
            startWithMoveTo: true,
          ),
          paint,
        );
        distance += dashWidth + dashSpace;
      }

      final startPos = metric.getTangentForOffset(0)?.position;
      if (startPos != null)
        canvas.drawCircle(startPos, 5, Paint()..color = Colors.black);

      final endPos = metric.getTangentForOffset(metric.length)?.position;
      if (endPos != null)
        canvas.drawCircle(endPos, 5, Paint()..color = Colors.black);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
