import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart'
    as location_service;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsCurrentLocationPicker extends StatefulWidget {
  final Function(String)?
  onLocationSelected; // Changed from Function(LatLng)? to Function(String)?
  final String? initialAddress;

  const GoogleMapsCurrentLocationPicker({
    super.key,
    this.onLocationSelected,
    this.initialAddress,
  });

  @override
  State<GoogleMapsCurrentLocationPicker> createState() =>
      _GoogleMapsCurrentLocationPickerState();
}

class _GoogleMapsCurrentLocationPickerState
    extends State<GoogleMapsCurrentLocationPicker> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  String _currentAddress = '';
  bool _isLoading = true;

  // Initialize LocationService
  final location_service.LocationService _locationService =
      location_service.LocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      // Use LocationService to get current position
      final position = await _locationService.getCurrentPosition();

      if (position == null) {
        _showErrorSnackBar(
          'Unable to get current location. Please check location permissions.',
        );
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = _currentLocation;
        _isLoading = false;
      });

      // Get address for current location using LocationService
      if (mounted) {
        await _getAddressFromLatLng(_currentLocation!, context);
      }

      // Animate camera to current location
      _animateToLocation(_currentLocation!);
    } catch (e) {
      _showErrorSnackBar('Error getting location: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng, BuildContext context) async {
    try {
      // Use LocationService for reverse geocoding
      final address = await _locationService.getFormattedAddressFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (address != null) {
        setState(() {
          _currentAddress = address;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, e.toString());
      }
    }
  }

  void _animateToLocation(LatLng location) {
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(location, 15.0));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_selectedLocation != null) {
      _animateToLocation(_selectedLocation!);
    }
  }

  void _onLocationConfirm() {
    if (_selectedLocation != null && widget.onLocationSelected != null) {
      // Return the address instead of coordinates
      widget.onLocationSelected!(_currentAddress);
      Navigator.of(
        context,
      ).pop(_currentAddress); // Return address instead of LatLng
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(0, 0),
                    zoom: 15.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  mapType: MapType.normal,
                ),
          // Address and button container positioned at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle for bottom sheet appearance
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (_currentAddress.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selected Location',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentAddress,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.black87,
                                      height: 1.3,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Confirm Location',
                      onPressed: _onLocationConfirm,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Back button positioned at top left
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Current location button positioned at top right
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.black),
                onPressed: _getCurrentLocation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
