import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:go_extra_mile_new/core/service/location_service.dart'
    hide LatLng;
import 'package:go_extra_mile_new/core/utils/marker_utils.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';



class RideGoogleMap extends StatefulWidget {
  final String currentLocationMarkerImageUrl;
  final List<RideMemoryEntity>? customMarkers; // Add custom markers parameter
  final Function(RideMemoryEntity)? onMemoryMarkerTapped; // Add callback for memory marker taps
  
  const RideGoogleMap({
    super.key, 
    required this.currentLocationMarkerImageUrl,
    this.customMarkers, // Make it optional
    this.onMemoryMarkerTapped, // Make it optional
  });

  @override
  State<RideGoogleMap> createState() => RideGoogleMapState();
}

class RideGoogleMapState extends State<RideGoogleMap> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  LatLng? _currentLocation;
  bool _isLocationLoaded = false;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLocationLoaded = true;
        });
        
        // Create custom marker for current location
        await _createCurrentLocationMarker();
        
        // Create custom markers if provided
        if (widget.customMarkers != null && widget.customMarkers!.isNotEmpty) {
          await _createCustomMarkers();
        }
        
        // If map controller is already available, animate to location
        if (_mapController != null) {
          _animateToLocation(_currentLocation!);
        }
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Set a default location if current location fails
      setState(() {
        _currentLocation = const LatLng(37.7749, -122.4194); // Default to San Francisco
        _isLocationLoaded = true;
      });
      await _createCurrentLocationMarker();
    }
  }

  Future<void> _createCurrentLocationMarker() async {
    if (_currentLocation == null) return;
    
    try {
      debugPrint('Creating current location marker. Current markers count: ${_markers.length}');
      
      // Create a custom circular marker for current location
      // You can pass an image URL here if you want to use a profile picture
      // For now, using empty string to get the fallback my-location style marker
      final BitmapDescriptor customMarker = await MarkerUtils.circularMarker(
        widget.currentLocationMarkerImageUrl, // Empty string will use the fallback my-location style marker
        size: 80,
        borderWidth: 3.0,
        borderColor: Colors.blue,
      );

      setState(() {
        // Remove existing current location marker if it exists
        _markers.removeWhere((marker) => marker.markerId.value == 'current_location');
        
        // Add new current location marker
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation!,
            icon: customMarker,
            infoWindow: const InfoWindow(
              title: 'Current Location',
              snippet: 'You are here',
            ),
          ),
        );
        
        debugPrint('Current location marker created. Total markers now: ${_markers.length}');
        debugPrint('Current location marker exists: ${_markers.any((m) => m.markerId.value == 'current_location')}');
      });
    } catch (e) {
      debugPrint('Error creating custom marker: $e');
    }
  }

  Future<void> _createCustomMarkers() async {
    if (widget.customMarkers == null || widget.customMarkers!.isEmpty) return;
    
    try {
      final Set<Marker> customMarkers = {};
      
      for (final markerData in widget.customMarkers!) {
        try {
          // Create rectangular marker using MarkerUtils
          final BitmapDescriptor markerIcon = await MarkerUtils.rectangularMarker(
            markerData.imageUrl,
            width: 140, // Constant width for memory markers
            height: 100, // Constant height for memory markers
            borderWidth: 4.0, // Constant border width for memory markers
            borderColor: memoryMarkerColors[Random().nextInt(memoryMarkerColors.length)], // Random color for each marker
            borderRadius: 12.0, // Constant border radius for memory markers
          );
          
          final Marker marker = Marker(
            markerId: MarkerId(markerData.id),
            position: LatLng(markerData.capturedCoordinates.latitude, markerData.capturedCoordinates.longitude),
            icon: markerIcon,
            infoWindow: InfoWindow(
              title: markerData.title,
              snippet: markerData.description,  
            ),
            onTap: () {
              // Call the callback when memory marker is tapped
              if (widget.onMemoryMarkerTapped != null) {
                widget.onMemoryMarkerTapped!(markerData);
              }
            },
          );
          
          customMarkers.add(marker);
        } catch (e) {
          debugPrint('Error creating marker ${markerData.id}: $e');
          // Continue with other markers even if one fails
        }
      }
      
      // Add custom markers to existing markers
      setState(() {
        _markers.addAll(customMarkers);
      });
      
    } catch (e) {
      debugPrint('Error creating custom markers: $e');
    }
  }

  // Method to add markers dynamically
  Future<void> addCustomMarker( RideMemoryEntity  rideMemory) async {
    try {
      final BitmapDescriptor markerIcon = await MarkerUtils.rectangularMarker(
        rideMemory.imageUrl,
        width: 100, // Constant width for memory markers
        height: 140, // Constant height for memory markers
        borderWidth: 4.0, // Constant border width for memory markers
        borderColor: memoryMarkerColors[Random().nextInt(memoryMarkerColors.length)], // Random color for each marker
        borderRadius: 12.0, // Constant border radius for memory markers
      );
      
      final Marker marker = Marker(
        markerId: MarkerId(rideMemory.id),
        position: LatLng(rideMemory.capturedCoordinates.latitude, rideMemory.capturedCoordinates.longitude),
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: rideMemory.title,
          snippet: rideMemory.description,
        ),
        onTap: () {
          // Call the callback when memory marker is tapped
          if (widget.onMemoryMarkerTapped != null) {
            widget.onMemoryMarkerTapped!(rideMemory);
          }
        },
      );
      
      setState(() {
        _markers.add(marker);
      });
    } catch (e) {
      debugPrint('Error adding custom marker: $e');
    }
  }

  // Method to remove a specific marker
  void removeMarker(String markerId) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == markerId);
    });
  }

  // Method to clear all custom markers (keeping only current location)
  void clearCustomMarkers() {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value != 'current_location');
    });
  }

  // Method to update marker position
  Future<void> updateMarkerPosition(String markerId, LatLng newPosition) async {
    final marker = _markers.firstWhere(
      (m) => m.markerId.value == markerId,
      orElse: () => throw Exception('Marker not found'),
    );
    
    // Remove old marker
    setState(() {
      _markers.remove(marker);
    });
    
    // Create new marker with updated position
    final newMarker = Marker(
      markerId: marker.markerId,
      position: newPosition,
      icon: marker.icon,
      infoWindow: marker.infoWindow,
    );
    
    setState(() {
      _markers.add(newMarker);
    });
  }

  // Method to get current map center position
  LatLng? getCurrentMapCenter() {
    if (_mapController != null && _currentLocation != null) {
      // For now, return current location as map center
      // In a more advanced implementation, you could track camera position changes
      return _currentLocation;
    }
    return null;
  }

  // Method to update custom markers
  Future<void> updateCustomMarkers(List<RideMemoryEntity> rideMemories) async {
    debugPrint('Updating custom markers. Current markers count: ${_markers.length}');
    debugPrint('Current location marker exists: ${_markers.any((m) => m.markerId.value == 'current_location')}');
    
    setState(() {
      // Clear existing custom markers (keep current location marker)
      _markers.removeWhere((marker) => marker.markerId.value != 'current_location');
    });
    
    debugPrint('After clearing custom markers. Markers count: ${_markers.length}');
    debugPrint('Current location marker still exists: ${_markers.any((m) => m.markerId.value == 'current_location')}');
    
    // Add new custom markers asynchronously
      for (final markerData in rideMemories) {
      await _createCustomMarker(markerData);
    }
    
    debugPrint('Finished updating custom markers. Final markers count: ${_markers.length}');
    debugPrint('Current location marker exists: ${_markers.any((m) => m.markerId.value == 'current_location')}');
  }

  // Handle memory capture and add new marker
  Future<RideMemoryEntity?> handleMemoryCaptured(String downloadUrl) async {
    // Get current map position (center of visible map)
    final currentPosition = getCurrentMapCenter();
    
    if (currentPosition != null) {
      // Create new memory marker
      final newMemoryMarker = RideMemoryEntity(
        id: UniqueKey().toString(),
        title: 'Ride Memory',
        description: 'Captured on ${DateTime.now().toString().substring(0, 16)}',
        imageUrl: downloadUrl,
        capturedCoordinates: GeoPoint(currentPosition.latitude, currentPosition.longitude),
        capturedAt: DateTime.now(),
      );

      // Add to markers list and update map
      await _createCustomMarker(newMemoryMarker);
      
      debugPrint('New memory marker added at: ${currentPosition.latitude}, ${currentPosition.longitude}');
      debugPrint('Image URL: $downloadUrl');
      
      // Return the created memory entity so the screen can store it
      return newMemoryMarker;
    }
    
    return null;
  }

  // Helper method to create a custom marker
  Future<void> _createCustomMarker(RideMemoryEntity markerData) async {
    try {
      final markerIcon = await MarkerUtils.rectangularMarker(
        markerData.imageUrl,
        width: 140, // Constant width for memory markers
        height: 100, // Constant height for memory markers
        borderWidth: 4.0, // Constant border width for memory markers
        borderColor: memoryMarkerColors[Random().nextInt(memoryMarkerColors.length)], // Random color for each marker
        borderRadius: 12.0, // Constant border radius for memory markers
      );

      final marker = Marker(
        markerId: MarkerId(markerData.id),
        position: LatLng(markerData.capturedCoordinates.latitude, markerData.capturedCoordinates.longitude),
        icon: markerIcon,
        infoWindow: InfoWindow(
          title: markerData.title,
          snippet: markerData.description,
        ),
        onTap: () {
          // Call the callback when memory marker is tapped
          if (widget.onMemoryMarkerTapped != null) {
            widget.onMemoryMarkerTapped!(markerData);
          }
        },
      );

      setState(() {
        _markers.add(marker);
        debugPrint('Added custom marker: ${markerData.id}. Total markers now: ${_markers.length}');
        debugPrint('Current location marker exists: ${_markers.any((m) => m.markerId.value == 'current_location')}');
      });
    } catch (e) {
      debugPrint('Error creating custom marker: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Automatically animate to current location when map is created
    if (_currentLocation != null && _isLocationLoaded) {
      // Use a small delay to ensure the map is fully rendered
      Future.delayed(const Duration(milliseconds: 100), () {
        _animateToLocation(_currentLocation!);
      });
    }
  }

  Future<void> animateToMyLocation() async {
    try {
      debugPrint('animateToMyLocation called. Current markers count: ${_markers.length}');
      debugPrint('Current location marker exists: ${_markers.any((m) => m.markerId.value == 'current_location')}');
      debugPrint('Custom markers count: ${_markers.where((m) => m.markerId.value != 'current_location').length}');
      
      final position = await _locationService.getCurrentPosition();
      if (position != null && _mapController != null) {
        final location = LatLng(position.latitude, position.longitude);
        
        // Store existing custom markers before updating current location
        final existingCustomMarkers = _markers.where((marker) => marker.markerId.value != 'current_location').toSet();
        debugPrint('Stored ${existingCustomMarkers.length} existing custom markers');
        
        setState(() {
          _currentLocation = location;
        });
        
        // Update current location marker
        await _createCurrentLocationMarker();
        
        // Restore custom markers
        setState(() {
          _markers.addAll(existingCustomMarkers);
          debugPrint('Restored custom markers. Total markers now: ${_markers.length}');
          debugPrint('Current location marker exists: ${_markers.any((m) => m.markerId.value == 'current_location')}');
        });
        
        _animateToLocation(location);
      }
    } catch (e) {
      // Handle error - could show a snackbar or dialog
      debugPrint('Error getting current location: $e');
    }
  }

  void _animateToLocation(LatLng location) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 17),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't build the map until we have location data
    if (!_isLocationLoaded) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    debugPrint('Building map with ${_markers.length} markers');
    debugPrint('Current location marker exists: ${_markers.any((m) => m.markerId.value == 'current_location')}');
    debugPrint('Custom markers count: ${_markers.where((m) => m.markerId.value != 'current_location').length}');

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _currentLocation!,
        zoom: 17,
      ),
      myLocationEnabled: false, // Disable default blue dot
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapType: MapType.normal,
      padding: const EdgeInsets.only(bottom: 100),
      markers: _markers, // Add custom markers
    );
  }
}
