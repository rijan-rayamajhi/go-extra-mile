import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/map_circular_button.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart' hide LatLng;
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import 'package:go_extra_mile_new/features/ride/data/models/ride_memory_model.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_google_map.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_capture_memory_button.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_sos_dilogue.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/save_ride_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideScreen extends StatefulWidget {
  final RideEntity rideEntity;
  final Map<String, String> selectedVechile;

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

  // Distance
  double _currentDistance = 0.0;
  Position? _lastPosition;

  // Speed
  double _currentSpeed = 0.0;
  double _maxSpeed = 0.0;
  DateTime? _lastPositionTime;

  // Time
  DateTime? _tripStartTime;
  Duration _currentDuration = Duration.zero;
  Timer? _tripTimer;
  
  // Route tracking
  List<GeoPoint> _routePoints = [];
  
  @override
  void initState() {
    super.initState();
    _allMemories = List<RideMemoryEntity>.from(
      widget.rideEntity.rideMemories ?? [],
    );

    // Start ride tracking
    _startDurationTracking();
    _startLocationTracking();
  }
 
  /// --- Start Location Tracking ---
  void _startLocationTracking() async {
    // Get initial position first
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

    // Start streaming location updates
    _locationStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      _updateDistance(position);
      _updateSpeed(position);
      _updateRoute(position);
    });
  }

  /// --- ROUTE TRACKING ---
  void _updateRoute(Position newPosition) {
    final newPoint = GeoPoint(newPosition.latitude, newPosition.longitude);
    
    // Add the new point to the route
    setState(() {
      _routePoints.add(newPoint);
    });
    
    // Update the map with the new route
    final mapState = _mapKey.currentState;
    if (mapState != null) {
      // Convert GeoPoint to LatLng for the map widget
      final latLngRoutePoints = _routePoints.map((point) => 
        LatLng(point.latitude, point.longitude)
      ).toList();
      mapState.updateRoute(latLngRoutePoints);
    }
  }

  /// --- DISTANCE CALCULATION ---
  void _updateDistance(Position newPosition) {
    if (_lastPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );

      if (distance > 0) {
        setState(() {
          _currentDistance += distance;
        });
      }
    }
    _lastPosition = newPosition;
  }

  /// --- SPEED CALCULATION ---
  void _updateSpeed(Position newPosition) {
    if (_lastPosition != null && _lastPositionTime != null) {
      DateTime currentTime = DateTime.now();
      Duration timeDiff = currentTime.difference(_lastPositionTime!);

      if (timeDiff.inMilliseconds > 0) {
        double distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );

        double speedInMs = distance / (timeDiff.inMilliseconds / 1000);
        double speedInKmh = speedInMs * 3.6;

        setState(() {
          _currentSpeed = speedInKmh;
          if (_currentSpeed > _maxSpeed) {
            _maxSpeed = _currentSpeed;
          }
        });
      }
    }
    _lastPositionTime = DateTime.now();
  }

  /// --- TIME TRACKING ---
  void _startDurationTracking() {
    _tripStartTime = DateTime.now();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentDuration = DateTime.now().difference(_tripStartTime!);
      });
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  void _handleMyLocationPressed() {
    final mapState = _mapKey.currentState;
    if (mapState != null) {
      mapState.animateToMyLocation();
    }
  }

  Future<void> _handleMemoryCaptured(String downloadUrl) async {
    final mapState = _mapKey.currentState;
    if (mapState != null) {
      final memory = await mapState.handleMemoryCaptured(downloadUrl);

      if (memory != null) {
        setState(() {
          _allMemories.add(memory);
        });

        final rideBloc = context.read<RideBloc>();
        final fields = {
          'rideMemories': _allMemories
              .map((memory) => RideMemoryModel.fromEntity(memory).toFirestore())
              .toList(),
        };
        rideBloc.add(
          UpdateRideFieldsEvent(
            userId: widget.rideEntity.userId,
            fields: fields,
          ),
        );
      }
      print('Memory captured and stored: ${memory?.id}');
    }
  }

  void _handleMemoryMarkerTapped(RideMemoryEntity rideMemory) {
    AppSnackBar.show(context, message: rideMemory.title);
  }

  Future<void> _handleEndRide() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();

      if (position == null) {
        AppSnackBar.show(context, message: 'Unable to get current location');
        return;
      }

      // Stop timers & streams
      _tripTimer?.cancel();
      await _locationStream?.cancel();
      
      // Store route points before clearing
      final finalRoutePoints = List<GeoPoint>.from(_routePoints);
      
      // Clear route tracking
      setState(() {
        _routePoints.clear();
      });

      // Calculate average speed
      double averageSpeed = _currentDistance > 0 && _currentDuration.inSeconds > 0 
          ? (_currentDistance / 1000) / (_currentDuration.inMinutes / 60) 
          : 0.0;

      final myRide = RideEntity(
        id: widget.rideEntity.id,
        userId: widget.rideEntity.userId,
        vehicleId: widget.rideEntity.vehicleId,
        status: "completed",
        startedAt: widget.rideEntity.startedAt,
        startCoordinates: widget.rideEntity.startCoordinates,
        endCoordinates: GeoPoint(position.latitude, position.longitude),
        endedAt: DateTime.now(),
        totalDistance: _currentDistance / 1000, // in km
        totalTime: _currentDuration.inMinutes.toDouble(),
        totalGEMCoins: (_currentDistance / 1000).floor().toDouble(), // Calculate GEM coins based on distance
        rideMemories: _allMemories,
        rideTitle: widget.rideEntity.rideTitle ?? 'Ride on ${DateTime.now().toString().split(' ')[0]}',
        rideDescription: widget.rideEntity.rideDescription ?? 'Completed ride with ${(_currentDistance / 1000).toStringAsFixed(2)} km distance',
        topSpeed: _maxSpeed,
        averageSpeed: averageSpeed,
        routePoints: finalRoutePoints,
      );

      // Debug logging
      debugPrint('=== RIDE ENTITY DEBUG ===');
      debugPrint('rideTitle: ${myRide.rideTitle}');
      debugPrint('rideDescription: ${myRide.rideDescription}');
      debugPrint('topSpeed: ${myRide.topSpeed}');
      debugPrint('averageSpeed: ${myRide.averageSpeed}');
      debugPrint('routePoints count: ${myRide.routePoints?.length ?? 0}');
      debugPrint('========================');

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SaveRideScreen(
            rideEntity: myRide,
            distance: _currentDistance / 1000,
            duration: _currentDuration,
            topSpeed: _maxSpeed,
            averageSpeed: averageSpeed,
          ),
        ),
      );
    } catch (e) {
      AppSnackBar.show(context, message: 'Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    _locationStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideFieldsUpdated) {
          AppSnackBar.show(context, message: 'Memory saved successfully!');
        } else if (state is RideFailure) {
          AppSnackBar.show(
            context,
            message: 'Failed to save memory: ${state.message}',
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            RideGoogleMap(
              key: _mapKey,
              currentLocationMarkerImageUrl: widget.selectedVechile['image']!,
              customMarkers: _allMemories,
              onMemoryMarkerTapped: _handleMemoryMarkerTapped,
              routePoints: _routePoints.map((point) => 
                LatLng(point.latitude, point.longitude)
              ).toList(),
            ),

            // Close button
            Positioned(
              left: 16,
              child: MapCircularButton(
                icon: Icons.close,
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),

            // GEM coin UI
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: IntrinsicWidth(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/gem_coin.png',
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                    // ... existing code ...
                          Text(
                            '${(_currentDistance / 1000).floor()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
// ... existing code ...
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // My location button
            Positioned(
              right: 16,
              child: MapCircularButton(
                icon: Icons.my_location,
                onPressed: _handleMyLocationPressed,
              ),
            ),

            // SOS button
            Positioned(
              bottom: 220 + 16,
              left: 16,
              child: MapCircularButton(
                icon: Icons.sos,
                backgroundColor: Colors.red,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const RideSOSDilogue(),
                  );
                },
              ),
            ),

            // Take picture button
            Positioned(
              bottom: 220 + 16,
              right: 16,
              child: RideCaptureMemoriesButton(
                onMemoryCaptured: _handleMemoryCaptured,
              ),
            ),

            // Bottom sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 250,
                width: double.infinity,
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
                        // Distance
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "${(_currentDistance / 1000).toStringAsFixed(2)} km",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Distance',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        // Speed
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                "${_currentSpeed.toStringAsFixed(1)} km/h",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Speed',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        // Time
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                _formatDuration(_currentDuration),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Time',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 200,
                      child: PrimaryButton(
                        text: 'End Ride',
                        onPressed: _handleEndRide,
                        icon: Icons.motorcycle,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vehicle image
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                child: CircularImage(
                  imageUrl: widget.selectedVechile['image']!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}