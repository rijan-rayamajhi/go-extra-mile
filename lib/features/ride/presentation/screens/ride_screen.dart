import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/map_circular_button.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart';
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

class RideScreen extends StatefulWidget {
  final RideEntity rideEntity;
  //selected vechile argument 
  final Map<String, String>  selectedVechile;
  const RideScreen({super.key, required this.rideEntity, required this.selectedVechile});

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  final GlobalKey<RideGoogleMapState> _mapKey = GlobalKey<RideGoogleMapState>();
  
  // List to store ALL memories (existing + newly captured)
  late List<RideMemoryEntity> _allMemories;

  @override
  void initState() {
    super.initState();
    // Initialize with existing memories from rideEntity
    _allMemories = List<RideMemoryEntity>.from(widget.rideEntity.rideMemories ?? []);
  }

  void _handleMyLocationPressed() {
    // Call the animateToMyLocation method on the map
    final mapState = _mapKey.currentState;
    if (mapState != null) {
      mapState.animateToMyLocation();
    }
  }

  // Handle memory capture and add new marker
  Future<void> _handleMemoryCaptured(String downloadUrl) async {
    final mapState = _mapKey.currentState;
    if (mapState != null) {
      // Delegate memory capture to the map widget and get the created memory entity
      final memory = await mapState.handleMemoryCaptured(downloadUrl);
      
      if (memory != null) {
        // Add the new memory to our complete list
        setState(() {
          _allMemories.add(memory);
        });

        // Update ride fields with ALL memories (existing + new)
        final rideBloc = context.read<RideBloc>();
        final fields = {
          'rideMemories': _allMemories.map((memory) => 
            RideMemoryModel.fromEntity(memory).toFirestore()
          ).toList(),
        };
        rideBloc.add(UpdateRideFieldsEvent(
          userId: widget.rideEntity.userId,
          fields: fields,
        ));
      }
      print('Memory captured and stored: ${memory?.id}');
    }
  }

  // Handle memory marker tap to open ImageViewer
  void _handleMemoryMarkerTapped(RideMemoryEntity rideMemory) {
    AppSnackBar.show(context, message: rideMemory.title);
  }

  // Handle end ride button press
  Future<void> _handleEndRide() async {
    try {
        
      // Get current position for end coordinates
      final locationService = LocationService();
      final position = await locationService.getCurrentPosition();
      
      if (position == null) {
        // Show error if unable to get location
        AppSnackBar.show(context, message: 'Unable to get current location');
        return;
      }
      
      final myRide = RideEntity(
        id: widget.rideEntity.id,
        userId: widget.rideEntity.userId,
        vehicleId: widget.rideEntity.vehicleId,
        status: widget.rideEntity.vehicleId,
        startedAt: widget.rideEntity.startedAt,
        startCoordinates: widget.rideEntity.startCoordinates,
        endCoordinates: GeoPoint(position.latitude, position.longitude),
        endedAt: DateTime.now(),
        totalDistance: 10,
        totalTime: 10.5,
        totalGEMCoins: 10,
        rideMemories: _allMemories, // Use the complete list of memories
      );
      
      // Print all ride data
      print('=== RIDE DATA ===');
      print('Ride ID: ${myRide.id}');
      print('User ID: ${myRide.userId}');
      print('Vehicle ID: ${myRide.vehicleId}');
      print('Status: ${myRide.status}');
      print('Started At: ${myRide.startedAt}');
      print('Start Coordinates: ${myRide.startCoordinates}');
      print('End Coordinates: ${myRide.endCoordinates}');
      print('Ended At: ${myRide.endedAt}');
      print('Total Distance: ${myRide.totalDistance} km');
      print('Total Time: ${myRide.totalTime} hours');
      print('Total GEM Coins: ${myRide.totalGEMCoins}');
      print('Total Memories Count: ${_allMemories.length}');
      print('Existing Memories: ${widget.rideEntity.rideMemories?.length ?? 0}');
      print('Newly Captured Memories: ${_allMemories.length - (widget.rideEntity.rideMemories?.length ?? 0)}');
      print('Selected Vehicle: ${widget.selectedVechile}');
      print('All Memories: ${_allMemories.map((m) => '${m.title} at ${m.capturedCoordinates}').join(', ')}');
      print('==================');
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SaveRideScreen(rideEntity: myRide),
        ),
      );
    } catch (e) {
      // Show error if location service fails
      AppSnackBar.show(context, message: 'Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideFieldsUpdated) {
          AppSnackBar.show(context, message: 'Memory saved successfully!');
        } else if (state is RideFailure) {
          AppSnackBar.show(context, message: 'Failed to save memory: ${state.message}');
        }
      },
      child: Scaffold(
        body: Stack(
        children: [
          RideGoogleMap(
            key: _mapKey,
            currentLocationMarkerImageUrl: widget.selectedVechile['image']!,
            customMarkers: _allMemories, // Pass the complete list of memories
            onMemoryMarkerTapped:
                _handleMemoryMarkerTapped, // Pass the callback
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

          //gem coin
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
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/icons/gem_coin.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '30',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // my location button
          Positioned(
            right: 16,
            child: MapCircularButton(
              icon: Icons.my_location,
              onPressed: _handleMyLocationPressed,
            ),
          ),

          // sos button
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

          // take picture button
          Positioned(
            bottom: 220 + 16,
            right: 16,
            child: RideCaptureMemoriesButton(
              onMemoryCaptured: _handleMemoryCaptured,
            ),
          ),
          //bottom sheet
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
                  SizedBox(height: 65),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                    children: [
                      // Distance
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '100 km',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Distance',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),

                      // Speed
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '100 km/h',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Speed',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),

                      // Time
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '00:00',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
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

                  SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    child: PrimaryButton(
                      text: 'End Ride',
                      onPressed: () => _handleEndRide(),
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
              child: CircularImage(imageUrl: widget.selectedVechile['image']!),
            ),
          ),
        ],
      ),
      )
    );
    
  }
}
