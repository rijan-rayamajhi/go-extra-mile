import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/map_circular_button.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart' hide LatLng;
import 'package:go_extra_mile_new/core/utils/marker_utils.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/odometer_entity.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/save_ride_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_capture_memory_button.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'odometer_camera_screen.dart';

class RideScreen extends StatefulWidget {
  final VehicleEntity selectedVechile;
  final String? beforeRideOdometerImage;

  const RideScreen({
    super.key, 
    required this.selectedVechile,
    this.beforeRideOdometerImage,
  });

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();

  // Location + route
  LatLng? _currentLocation;
  bool _isLocationLoaded = false;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _routePoints = [];

  // Memories
  final List<RideMemoryEntity> _allMemories = [];
  
  // Odometer images
  String? _beforeRideOdometerImage;

  // Ride stats
  double _currentDistance = 0.0;
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  Position? _initialPosition;
  Position? _lastPosition;
  DateTime? _lastPositionTime;

  // Duration
  DateTime? _tripStartTime;
  Duration _currentDuration = Duration.zero;
  Timer? _tripTimer;

  // Subscriptions
  StreamSubscription<Position>? _locationStream;

  // UI
  bool _isEndingRide = false;

  // Constants
  static const double _minDistanceThreshold = 5.0;
  static const double _maxAllowedSpeed = 60.0; // m/s

  // Marker sizes
  static const double _memoryMarkerWidth = 80;
  static const double _memoryMarkerHeight = 100;

  @override
  void initState() {
    super.initState();
    _beforeRideOdometerImage = widget.beforeRideOdometerImage;
    _initLocation();
    _startDurationTracking();
    _startLocationTracking();
  }

  // ---------------- Location ----------------
  Future<void> _initLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        _setCurrentLocation(LatLng(position.latitude, position.longitude));
        await _updateCurrentLocationMarker();
        _animateToLocation(_currentLocation!);
      }
    } catch (e) {
      debugPrint("⚠️ Error getting location: $e");
      _setCurrentLocation(const LatLng(37.7749, -122.4194));
      await _updateCurrentLocationMarker();
    }
  }

  void _setCurrentLocation(LatLng location) {
    setState(() {
      _currentLocation = location;
      _isLocationLoaded = true;
    });
  }

  void _animateToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 17),
      ),
    );
  }

  Future<void> _updateCurrentLocationMarker() async {
    if (_currentLocation == null) return;

    final icon = await MarkerUtils.circularMarker(
      widget.selectedVechile.vehicleBrandImage,
      size: 24,
      borderWidth: 1.0,
      borderColor: Colors.blue,
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'current_location');
      _markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        icon: icon,
        infoWindow: const InfoWindow(title: 'You are here'),
      ));
    });
  }

  // ---------------- Location Tracking ----------------
  Future<void> _startLocationTracking() async {
    try {
      _initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
      );
      _lastPosition = _initialPosition; // Set last position to initial position
      _updateRoute(_initialPosition!);
      debugPrint("✅ Initial position set: ${_initialPosition!.latitude}, ${_initialPosition!.longitude}");
    } catch (e) {
      debugPrint("⚠️ Error getting initial pos: $e");
      // Try again with a fallback approach
      try {
        _initialPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
        );
        _lastPosition = _initialPosition;
        debugPrint("✅ Initial position set with fallback: ${_initialPosition!.latitude}, ${_initialPosition!.longitude}");
      } catch (e2) {
        debugPrint("⚠️ Failed to get initial position even with fallback: $e2");
      }
    }

    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen(_handleLocationUpdate);
  }

  void _handleLocationUpdate(Position pos) {
    final now = DateTime.now();

    if (_lastPosition != null && _lastPositionTime != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
      final timeDiffSec = now.difference(_lastPositionTime!).inSeconds;

      if (timeDiffSec > 0) {
        final speedMps = distance / timeDiffSec;
        if (distance >= _minDistanceThreshold && speedMps <= _maxAllowedSpeed) {
          _currentDistance += distance;
          _currentSpeed = speedMps * 3.6;
          _maxSpeed = max(_maxSpeed, _currentSpeed);

          _updateRoute(pos);
          _lastPosition = pos;
          _lastPositionTime = now;
        }
      }
    } else {
      _lastPosition = pos;
      _lastPositionTime = now;
    }
  }

  void _updateRoute(Position pos) {
    final newPoint = GeoPoint(pos.latitude, pos.longitude);
    _routePoints.add(LatLng(newPoint.latitude, newPoint.longitude));

    setState(() {
      _polylines
        ..clear()
        ..add(Polyline(
          polylineId: const PolylineId('ride_route'),
          points: _routePoints,
          color: Colors.blue,
          width: 4,
          geodesic: true,
        ));
    });
  }

  // ---------------- Memories ----------------
  Future<void> _handleMemoryCaptured(String url) async {
    if (_currentLocation == null) return;

    final memory = RideMemoryEntity(
      id: const Uuid().v4(),
      title: 'Ride Memory',
      description: 'Captured on ${DateTime.now()}',
      imageUrl: url,
      capturedCoordinates: GeoPoint(_currentLocation!.latitude, _currentLocation!.longitude),
      capturedAt: DateTime.now(),
    );

    final icon = await MarkerUtils.rectangularMarker(
      memory.imageUrl,
      width: _memoryMarkerWidth.toInt(),
      height: _memoryMarkerHeight.toInt(),
      borderWidth: 2.0,
      borderRadius: 8.0,
      borderColor: memoryMarkerColors[Random().nextInt(memoryMarkerColors.length)],
    );

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(memory.id),
        position: LatLng(memory.capturedCoordinates.latitude, memory.capturedCoordinates.longitude),
        icon: icon,
        onTap: () => AppSnackBar.show(context, message: memory.title),
      ));
      _allMemories.add(memory);
    });
  }

  // ---------------- Duration ----------------
  void _startDurationTracking() {
    _tripStartTime = DateTime.now();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentDuration = DateTime.now().difference(_tripStartTime!);
        });
      }
    });
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  // ---------------- End Ride ----------------
  Future<void> _handleEndRide() async {
    setState(() => _isEndingRide = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        AppSnackBar.showSnackBar(context, 'Please sign in first');
        return;
      }

      // Check if ride data is available
      if (_tripStartTime == null) {
        AppSnackBar.show(context, message: 'Ride not properly started');
        return;
      }

      if (_initialPosition == null) {
        AppSnackBar.show(context, message: 'Initial position not available');
        return;
      }

      if (_lastPosition == null) {
        AppSnackBar.show(context, message: 'Last position not available');
        return;
      }

      _tripTimer?.cancel();
      await _locationStream?.cancel();

      final ride = RideEntity(
        id: const Uuid().v4(),
        userId: currentUser.uid,
        vehicleId: widget.selectedVechile.id,
        status: "completed",
        startedAt: _tripStartTime!,
        startCoordinates: GeoPoint(_initialPosition!.latitude, _initialPosition!.longitude),
        endCoordinates: GeoPoint(_lastPosition!.latitude, _lastPosition!.longitude),
        endedAt: DateTime.now(),
        totalDistance: _currentDistance,
        totalTime: _currentDuration.inSeconds.toDouble(),
        totalGEMCoins: gemCoins,
        rideMemories: _allMemories,
        rideTitle: 'Ride on ${DateTime.now().toString().split(' ')[0]}',
        rideDescription: 'Completed ride with ${distanceKm.toStringAsFixed(2)} km distance',
        topSpeed: _maxSpeed,
        averageSpeed: _calculateAverageSpeed(),
        routePoints: _routePoints.map((p) => GeoPoint(p.latitude, p.longitude)).toList(),
        isPublic: true,
        odometer: _beforeRideOdometerImage != null 
            ? OdometerEntity(
                id: const Uuid().v4(),
                beforeRideOdometerImage: _beforeRideOdometerImage,
                beforeRideOdometerImageCaptureAt: DateTime.now(),
              )
            : null,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SaveRideScreen(
              rideEntity: ride,
              selectedVehicle: widget.selectedVechile,
            ),
          ),
        );
      }
    } catch (e) {
      AppSnackBar.show(context, message: 'Error: $e');
    } finally {
      setState(() => _isEndingRide = false);
    }
  }

  double get distanceKm => _currentDistance / 1000;
  double get gemCoins => distanceKm;

  double _calculateAverageSpeed() {
    if (_currentDistance <= 0 || _currentDuration.inSeconds <= 0) return 0.0;
    return distanceKm / (_currentDuration.inSeconds / 3600);
  }

  // ---------------- Lifecycle ----------------
  @override
  void dispose() {
    _tripTimer?.cancel();
    _locationStream?.cancel();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (!_isLocationLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocConsumer<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideFailure) {
          AppSnackBar.show(context, message: 'Failed: ${state.message}');
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                onMapCreated: (c) => _mapController = c,
                initialCameraPosition: CameraPosition(target: _currentLocation!, zoom: 17),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
                padding: const EdgeInsets.only(bottom: 100),
                markers: _markers,
                polylines: _polylines,
              ),
              Positioned(left: 16, child: MapCircularButton(icon: Icons.close, onPressed: _showExitRideDialog)),
              Positioned(right: 16, child: MapCircularButton(icon: Icons.my_location, onPressed: () => _animateToLocation(_currentLocation!))),
              _buildGemCoinUI(),
              Positioned(bottom: 220, right: 16, child: RideCaptureMemoriesButton(onMemoryCaptured: _handleMemoryCaptured)),
              _buildBottomSheet(),
              _buildVehicleImage(),
              if (state is RideLoading) _buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() => Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );

  Widget _buildGemCoinUI() => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: Center(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icons/gem_coin.png', width: 24, height: 24),
                  const SizedBox(width: 8),
                  Text(gemCoins.toStringAsFixed(2), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildBottomSheet() => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 65),
              _buildStatRow(),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );

  Widget _buildStatRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat("${distanceKm.toStringAsFixed(2)} km", "Distance"),
          _divider(),
          _buildStat("${_currentSpeed.toStringAsFixed(1)} km/h", "Speed"),
          _divider(),
          _buildStat(_formatDuration(_currentDuration), "Time"),
        ],
      );

  Widget _buildActionButtons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _buildCustomOutlinedButton(
                text: 'Capture Odometer',
                onPressed: _navigateToOdometerCamera,
                icon: Icons.camera_alt,
                borderColor: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCustomButton(
                text: _isEndingRide ? 'Ending...' : 'End Ride',
                onPressed: _isEndingRide ? null : _handleEndRide,
                icon: Icons.motorcycle,
                backgroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );

  Widget _buildStat(String value, String label) => Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );

  Widget _divider() => Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3));

  Widget _buildCustomButton({
    required String text,
    required VoidCallback? onPressed,
    required IconData icon,
    required Color backgroundColor,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomOutlinedButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    required Color borderColor,
  }) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: borderColor,
        side: BorderSide(color: borderColor, width: 2),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOdometerCamera() async {
    // End the ride first
    await _handleEndRideForOdometer();
  }

  Future<void> _handleEndRideForOdometer() async {
    setState(() => _isEndingRide = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        AppSnackBar.showSnackBar(context, 'Please sign in first');
        return;
      }

      // Check if ride data is available
      if (_tripStartTime == null) {
        AppSnackBar.show(context, message: 'Ride not properly started');
        return;
      }

      // If initial position is not available, try to get it now
      if (_initialPosition == null) {
        try {
          AppSnackBar.show(context, message: 'Getting current position...');
          _initialPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
          );
        } catch (e) {
          AppSnackBar.show(context, message: 'Unable to get current position: $e');
          return;
        }
      }

      // If last position is not available, use initial position or get current position
      if (_lastPosition == null) {
        _lastPosition = _initialPosition;
      }

      _tripTimer?.cancel();
      await _locationStream?.cancel();

      final ride = RideEntity(
        id: const Uuid().v4(),
        userId: currentUser.uid,
        vehicleId: widget.selectedVechile.id,
        status: "completed",
        startedAt: _tripStartTime!,
        startCoordinates: GeoPoint(_initialPosition!.latitude, _initialPosition!.longitude),
        endCoordinates: GeoPoint(_lastPosition!.latitude, _lastPosition!.longitude),
        endedAt: DateTime.now(),
        totalDistance: _currentDistance,
        totalTime: _currentDuration.inSeconds.toDouble(),
        totalGEMCoins: gemCoins,
        rideMemories: _allMemories,
        rideTitle: 'Ride on ${DateTime.now().toString().split(' ')[0]}',
        rideDescription: 'Completed ride with ${distanceKm.toStringAsFixed(2)} km distance',
        topSpeed: _maxSpeed,
        averageSpeed: _calculateAverageSpeed(),
        routePoints: _routePoints.map((p) => GeoPoint(p.latitude, p.longitude)).toList(),
        isPublic: true,
        odometer: _beforeRideOdometerImage != null 
            ? OdometerEntity(
                id: const Uuid().v4(),
                beforeRideOdometerImage: _beforeRideOdometerImage,
                beforeRideOdometerImageCaptureAt: DateTime.now(),
              )
            : null,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OdometerCameraScreen(
              selectedVehicle: widget.selectedVechile,
              rideEntity: ride,
              odometerType: OdometerType.afterRide,
            ),
          ),
        );
      }
    } catch (e) {
      AppSnackBar.show(context, message: 'Error ending ride: $e');
    } finally {
      setState(() => _isEndingRide = false);
    }
  }

  Widget _buildVehicleImage() => Positioned(
        bottom: 180,
        left: 0,
        right: 0,
        child: Center(child: CircularImage(imageUrl: widget.selectedVechile.vehicleBrandImage)),
      );

  void _showExitRideDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit Ride'),
        content: const Text(
          'Are you sure you want to exit? This will end your current ride and all progress will be lost.\n\nBackground Ride Tracking Coming Soon..',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit Ride'),
          ),
        ],
      ),
    );
  }
}