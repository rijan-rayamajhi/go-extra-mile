import 'package:flutter/material.dart';
// PrimaryButton is imported in the bottom sheet where it's used
import 'package:go_extra_mile_new/features/ride/presentation/widgets/select_vehicle_for_rider_bottom_sheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/service/location_service.dart' hide LatLng;

class RideVehicleScreen extends StatefulWidget {
  const RideVehicleScreen({super.key});

  @override
  State<RideVehicleScreen> createState() => _RideVehicleScreenState();
}

class _RideVehicleScreenState extends State<RideVehicleScreen> {
  final LocationService _locationService = LocationService();

  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _isLoading = true;
  String? _errorMessage;

  // Add missing variables
  final PageController _pageController = PageController();

  // Add markers list
  Set<Marker> _markers = {};
  
  // Add selected vehicle index (default to first vehicle so a marker is shown immediately)
  int? _selectedVehicleIndex = 0;
  
  // Map bottom padding to keep marker slightly above center due to bottom sheet
  final double _mapPaddingBottom = 220.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Get current location
      final position = await _locationService.getCurrentPosition();

      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });

        // Create marker for selected vehicle at current location
        await _createSelectedVehicleMarker();

        // Animate camera to current location
        _animateToCurrentLocation();
      } else {
        setState(() {
          _errorMessage =
              'Unable to get current location. Please check location permissions.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createSelectedVehicleMarker() async {
    if (_currentLocation == null) return;

    // If no vehicle is selected, don't show any marker
    if (_selectedVehicleIndex == null) {
      setState(() {
        _markers = {};
      });
      return;
    }

    // Since vehicles are now loaded through the bloc in the bottom sheet,
    // we'll create a simple default marker for now
    // The actual vehicle-specific marker will be created when a vehicle is selected
    final defaultMarker = Marker(
      markerId: const MarkerId('selected_vehicle'),
      position: _currentLocation!,
      infoWindow: const InfoWindow(
        title: 'Selected Vehicle',
        snippet: 'Your selected vehicle',
      ),
    );

    setState(() {
      _markers = {defaultMarker};
    });
  }

  void _onVehicleSelected(int vehicleIndex) {
    setState(() {
      _selectedVehicleIndex = vehicleIndex;
    });
    
    // Create marker for the selected vehicle
    _createSelectedVehicleMarker();
  }

  void _animateToCurrentLocation() {
    if (_mapController != null && _currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLocation!, zoom: 15.0),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _animateToCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentLocation ?? const LatLng(0, 0),
            zoom: 20.0,
          ),
          padding: EdgeInsets.only(bottom: _mapPaddingBottom),
          myLocationEnabled: true, // Disable default blue marker
          myLocationButtonEnabled: false, // We have our own FABxF
        ),
        Positioned( 
          left: 16,
          child: SafeArea(
            child: Material(
              color: Colors.white.withOpacity(0.8),
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                tooltip: 'Close',
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
              ),
            ),
          ),
        ),
                 Positioned(
          right: 16,
          child: SafeArea(
            child: Material(
              color: Colors.white.withOpacity(0.8),
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.black),
                tooltip: 'My Location',
                onPressed: () {
                  _animateToCurrentLocation();
                },
              ),
            ),
          ),
        ),

        // Bottom sheet with divider
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SelectVehicleForRiderBottomSheet(
            onVehicleSelected: _onVehicleSelected,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
