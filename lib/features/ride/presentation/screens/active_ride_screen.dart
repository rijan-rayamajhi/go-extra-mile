import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/vehicle_circular_image_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_extra_mile_new/core/utils/image_picker_utils.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/save_ride_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/odometer_camera_screen.dart';
import 'package:go_extra_mile_new/features/main/main_screen.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/common/widgets/secondary_button.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/active_ride_ride_stats_row.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/active_ride_ride_top_controls.dart';
import 'package:go_extra_mile_new/features/ride/utils.dart';

class ActiveRideScreen extends StatefulWidget {
  const ActiveRideScreen({super.key});

  @override
  State<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends State<ActiveRideScreen> {
  GoogleMapController? _mapController;
  bool _followUser = true;
  Set<Marker> _markers = {};
  Set<String> _addedMemoryIds = {}; // To prevent duplicate markers
  void _moveCameraTo(LatLng position, {double zoom = 17, bool animate = true}) {
    if (_mapController == null) return;
    final update = CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: zoom),
    );
    if (animate) {
      _mapController!.animateCamera(update);
    } else {
      _mapController!.moveCamera(update);
    }
  }

  LatLng? _getCurrentCoordinates(RideState state) {
    final points = state.currentRide?.routePoints;
    if (points != null && points.isNotEmpty) {
      final last = points.last;
      return LatLng(last.latitude, last.longitude);
    }
    final start = state.currentRide?.startCoordinates;
    if (start != null) {
      return LatLng(start.latitude, start.longitude);
    }
    return null;
  }

  /// Adds an image marker with rounded corners and black border
  Future<void> addImageMarker(RideMemoryEntity memory) async {
    final memoryId = memory.id ?? memory.capturedAt.toString();
    if (_addedMemoryIds.contains(memoryId)) return; // avoid duplicates

    final bitmap = await bitmapFromFileWithBorder(
      File(memory.imageUrl ?? ''),
      width: 120,
      height: 120,
      borderRadius: 16,
      borderWidth: 4,
      borderColor: Colors.black,
    );

    final marker = Marker(
      markerId: MarkerId('memory_marker_$memoryId'),
      position: LatLng(
        memory.capturedCoordinates!.latitude,
        memory.capturedCoordinates!.longitude,
      ),
      icon: bitmap,
    );

    setState(() {
      _markers.add(marker);
      _addedMemoryIds.add(memoryId);
    });
  }

  void addAllMemoryMarkers(List<RideMemoryEntity> memories) {
    for (var memory in memories) {
      addImageMarker(memory);
    }
  }

  Future<LatLng?> _getUserCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever)
          return null;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: BlocConsumer<RideBloc, RideState>(
          listener: (context, state) async {
            final current = _getCurrentCoordinates(state);
            if (_followUser && current != null) {
              _moveCameraTo(current);
            }

            if ((state.currentRide?.rideMemories?.isNotEmpty ?? false)) {
              addAllMemoryMarkers(state.currentRide!.rideMemories!);
            }
          },
          builder: (context, state) {
            final startCoords = state.currentRide?.startCoordinates;
            if (startCoords == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final vehicleId = state.currentRide?.vehicleId ?? '';
            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(startCoords.latitude, startCoords.longitude),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: _markers,
                  onMapCreated: (controller) => _mapController = controller,
                  polylines: {
                    if ((state.currentRide?.routePoints?.isNotEmpty ?? false))
                      Polyline(
                        polylineId: const PolylineId('ride_path'),
                        points: filteredPoints(
                          state.currentRide!.routePoints!
                              .map((p) => LatLng(p.latitude, p.longitude))
                              .toList(),
                          minDistance: 5,
                        ),
                        color: Colors.blue,
                        width: 5,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                      ),
                  },
                  padding: const EdgeInsets.only(bottom: 200),
                ),

                RideTopControls(
                  gemCoins: (state.currentRide?.totalDistance ?? 0) / 1000,
                  onClose: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                      (Route<dynamic> route) => false, // remove all
                    );
                  },
                  onCurrentLocation: () {
                    context.read<RideBloc>().add(MoveToCurrentLocation());
                    _followUser = true;
                  },
                ),

                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 50),
                          if (vehicleId.isNotEmpty)
                            Text(
                              'Always wear a helmet, follow traffic rules, stay alert, and ride safely with proper gear.',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 20),
                          RideStatsRow(
                            distanceKm:
                                (state.currentRide?.totalDistance ?? 0) / 1000,
                            speed: state.currentRide?.averageSpeed ?? 0,
                            duration: state.currentRide?.totalTime != null
                                ? Duration(
                                    seconds: state.currentRide!.totalTime!
                                        .toInt(),
                                  )
                                : Duration.zero,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: SecondaryButton(
                                  text: 'Odometer',
                                  onPressed: () async {
                                    final capturedImage = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OdometerCameraScreen(
                                              isBeforeRide: false,
                                            ),
                                      ),
                                    );
                                    if (capturedImage != null) {
                                      context.read<RideBloc>().add(
                                        SaveAfterRideOdometerImage(
                                          capturedImage['file'],
                                          capturedImage['capturedAt'],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PrimaryButton(
                                  text: 'End Ride',
                                  onPressed: () {
                                    context.read<RideBloc>().add(
                                      StopTracking(),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SaveRideScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (state.currentRide?.vehicleId != null)
                  Positioned(
                    bottom: 260,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: VehicleCircularImageWidget(
                        vehicleId: state.currentRide!.vehicleId!,
                      ),
                    ),
                  ),

                Positioned(
                  bottom: 330,
                  right: 16,
                  child: Container(
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
                    child: IconButton(
                      icon: const Icon(Icons.camera, color: Colors.black),
                      onPressed: () async {
                        final File? pickedImage =
                            await ImagePickerUtils.pickAndCropImage(
                              context: context,
                            );
                        if (pickedImage != null) {
                          final current = await _getUserCurrentLocation();
                          if (current != null) {
                            context.read<RideBloc>().add(
                              SaveRideMemory({
                                'id': UniqueKey().toString(), // optional
                                'title': 'Some title', // optional
                                'description': 'Some description', // optional
                                'imageUrl': pickedImage
                                    .path, // required — file path of image
                                'coordinates': GeoPoint(
                                  current.latitude,
                                  current.longitude,
                                ), // required
                                'capturedAt':
                                    DateTime.now(), // optional, can default to now
                              }),
                            );
                          } else {
                            pickedImage.deleteSync();
                          }
                        }
                      },
                      padding: EdgeInsets.zero,
                      iconSize: 24,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
