import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/map_circular_button.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart'
    hide LatLng;
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_google_map.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_capture_memory_button.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/save_ride_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideScreen extends StatefulWidget {
  final RideEntity rideEntity;
  final VehicleEntity selectedVechile;

  const RideScreen({
    super.key,
    required this.rideEntity,
    required this.selectedVechile,
  });

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  final GlobalKey<RideGoogleMapState> _mapKey = GlobalKey<RideGoogleMapState>();

  late List<RideMemoryEntity> _allMemories;
  StreamSubscription<Position>? _locationStream;

  // Ride stats
  double _currentDistance = 0.0; // meters
  double _currentSpeed = 0.0; // km/h
  double _maxSpeed = 0.0;
  Position? _lastPosition;
  DateTime? _lastPositionTime;

  // Duration
  DateTime? _tripStartTime;
  Duration _currentDuration = Duration.zero;
  Timer? _tripTimer;

  // Route
  final List<GeoPoint> _routePoints = [];

  // UI state
  bool _isEndingRide = false;

  @override
  void initState() {
    super.initState();
    _allMemories = List<RideMemoryEntity>.from(
      widget.rideEntity.rideMemories ?? [],
    );
    _startDurationTracking();
    _startLocationTracking();
  }

  // -------------------- Location Tracking --------------------

  Future<void> _startLocationTracking() async {
    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
      _updateRoute(initialPosition);
    } catch (e) {
      debugPrint('Error getting initial position: $e');
    }

    _locationStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // update only if moved 10m+
          ),
        ).listen((pos) {
          _updateDistance(pos);
          _updateSpeed(pos);
          _updateRoute(pos);
        });
  }

  void _updateRoute(Position pos) {
    final newPoint = GeoPoint(pos.latitude, pos.longitude);
    _routePoints.add(newPoint);

    final mapState = _mapKey.currentState;
    if (mapState != null) {
      final latLngPoints = _routePoints
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
      mapState.updateRoute(latLngPoints);
    }
  }

  // Configurable thresholds
  static const double _minDistanceThreshold = 5.0; // meters
  static const double _maxAllowedSpeed = 60.0; // m/s (~216 km/h)

  // -------------------- Distance --------------------
  void _updateDistance(Position newPos) {
    if (_lastPosition != null && _lastPositionTime != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPos.latitude,
        newPos.longitude,
      );

      final timeDiffSec = DateTime.now()
          .difference(_lastPositionTime!)
          .inSeconds;

      if (timeDiffSec > 0) {
        final speed = distance / timeDiffSec; // m/s

        // ✅ Only accept if movement is valid
        if (distance >= _minDistanceThreshold && speed <= _maxAllowedSpeed) {
          _currentDistance += distance;
          _lastPosition = newPos;
          _lastPositionTime = DateTime.now();
        }
      }
    } else {
      // First position
      _lastPosition = newPos;
      _lastPositionTime = DateTime.now();
    }
  }

  // -------------------- Speed --------------------
  void _updateSpeed(Position newPos) {
    if (_lastPosition != null && _lastPositionTime != null) {
      final currentTime = DateTime.now();
      final timeDiff = currentTime
          .difference(_lastPositionTime!)
          .inMilliseconds;

      if (timeDiff > 0) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          newPos.latitude,
          newPos.longitude,
        );

        final speedMps = distance / (timeDiff / 1000.0);
        final speedKmh = speedMps * 3.6;

        // ✅ Ignore unrealistic spikes
        if (speedMps <= _maxAllowedSpeed) {
          _currentSpeed = speedKmh;
          _maxSpeed = _currentSpeed > _maxSpeed ? _currentSpeed : _maxSpeed;
        }
      }
    }
    _lastPositionTime = DateTime.now();
  }

  // -------------------- Duration --------------------

  void _startDurationTracking() {
    _tripStartTime = DateTime.now();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _currentDuration = DateTime.now().difference(_tripStartTime!);
      });
    });
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  // -------------------- Memories --------------------

  Future<void> _handleMemoryCaptured(String url) async {
    final mapState = _mapKey.currentState;
    if (mapState == null) return;

    final memory = await mapState.handleMemoryCaptured(url);
    if (memory == null) return;

    setState(() => _allMemories.add(memory));
  }

  void _handleMemoryMarkerTapped(RideMemoryEntity memory) {
    AppSnackBar.show(context, message: memory.title);
  }

  // -------------------- Exit / End Ride --------------------

  void _showExitRideDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit Ride'),
        content: const Text(
          'Are you sure you want to exit? This will end your current ride and all progress will be lost.\n\nBackground Ride Tracking Coming Soon..',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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

  Future<void> _handleEndRide() async {
    setState(() => _isEndingRide = true);
    try {
      final position = await LocationService().getCurrentPosition();
      if (position == null) {
        if (mounted) {
          AppSnackBar.show(context, message: 'Unable to get current location');
        }
        return;
      }

      _tripTimer?.cancel();
      await _locationStream?.cancel();

      final finalRoutePoints = List<GeoPoint>.from(_routePoints);
      _routePoints.clear();

      final avgSpeed = _calculateAverageSpeed();

      final ride = RideEntity(
        id: widget.rideEntity.id,
        userId: widget.rideEntity.userId,
        vehicleId: widget.rideEntity.vehicleId,
        status: "completed",
        startedAt: widget.rideEntity.startedAt,
        startCoordinates: widget.rideEntity.startCoordinates,
        endCoordinates: GeoPoint(position.latitude, position.longitude),
        endedAt: DateTime.now(),
        totalDistance: _currentDistance,
        totalTime: _currentDuration.inSeconds.toDouble(),
        totalGEMCoins: _currentDistance / 1000,
        rideMemories: _allMemories,
        rideTitle:
            widget.rideEntity.rideTitle ??
            'Ride on ${DateTime.now().toString().split(' ')[0]}',
        rideDescription:
            widget.rideEntity.rideDescription ??
            'Completed ride with ${(_currentDistance / 1000).toStringAsFixed(2)} km distance',
        topSpeed: _maxSpeed,
        averageSpeed: avgSpeed,
        routePoints: finalRoutePoints,
        isPublic: widget.rideEntity.isPublic ?? true, // Default to public if not set
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
      if (mounted) {
        AppSnackBar.show(context, message: 'Error: $e');
      }
    } finally {
      setState(() => _isEndingRide = false);
    }
  }

  double _calculateAverageSpeed() {
    if (_currentDistance <= 0 || _currentDuration.inSeconds <= 0) return 0.0;
    final km = _currentDistance / 1000;
    final hours = _currentDuration.inSeconds / 3600;
    return hours > 0 ? km / hours : 0.0;
  }

  // -------------------- Lifecycle --------------------

  @override
  void dispose() {
    _tripTimer?.cancel();
    _locationStream?.cancel();
    super.dispose();
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideFailure) {
          AppSnackBar.show(context, message: 'Failed: ${state.message}');
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) => !didPop ? _showExitRideDialog() : null,
          child: Scaffold(
            body: Stack(
              children: [
                if (state is RideLoading) _buildLoadingOverlay(),

                RideGoogleMap(
                  key: _mapKey,
                  currentLocationMarkerImageUrl:
                      widget.selectedVechile.vehicleBrandImage,
                  customMarkers: _allMemories,
                  onMemoryMarkerTapped: _handleMemoryMarkerTapped,
                  routePoints: _routePoints
                      .map((p) => LatLng(p.latitude, p.longitude))
                      .toList(),
                ),

                Positioned(
                  left: 16,
                  child: MapCircularButton(
                    icon: Icons.close,
                    onPressed: _showExitRideDialog,
                  ),
                ),
                Positioned(
                  right: 16,
                  child: MapCircularButton(
                    icon: Icons.my_location,
                    onPressed: _handleMyLocationPressed,
                  ),
                ),

                _buildGemCoinUI(),
                _buildCaptureButton(),
                _buildBottomSheet(),
                _buildVehicleImage(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingOverlay() => Positioned.fill(
    child: Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(child: CircularProgressIndicator()),
    ),
  );

  Widget _buildGemCoinUI() => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Center(
        child: IntrinsicWidth(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/gem_coin.png', width: 24, height: 24),
                const SizedBox(width: 8),
                Text(
                  (_currentDistance / 1000).toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildCaptureButton() => Positioned(
    bottom: 236,
    right: 16,
    child: RideCaptureMemoriesButton(onMemoryCaptured: _handleMemoryCaptured),
  );

  Widget _buildBottomSheet() => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      height: 250,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 65),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStat(
                "${(_currentDistance / 1000).toStringAsFixed(2)} km",
                "Distance",
              ),
              _divider(),
              _buildStat("${_currentSpeed.toStringAsFixed(1)} km/h", "Speed"),
              _divider(),
              _buildStat(_formatDuration(_currentDuration), "Time"),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: PrimaryButton(
              text: _isEndingRide ? 'Ending...' : 'End Ride',
              onPressed: () {
                if (_isEndingRide) return;
                _handleEndRide();
              },
              icon: Icons.motorcycle,
              isLoading: _isEndingRide,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStat(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );

  Widget _divider() =>
      Container(height: 40, width: 1, color: Colors.grey.withValues(alpha: 0.3));

  Widget _buildVehicleImage() => Positioned(
    bottom: 200,
    left: 0,
    right: 0,
    child: Center(
      child: CircularImage(imageUrl: widget.selectedVechile.vehicleBrandImage),
    ),
  );

  void _handleMyLocationPressed() =>
      _mapKey.currentState?.animateToMyLocation();
}
