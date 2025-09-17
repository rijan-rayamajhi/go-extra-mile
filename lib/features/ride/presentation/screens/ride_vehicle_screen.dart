
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service/location_service.dart' hide LatLng;
import '../../../../core/di/injection_container.dart';
import '../../../../common/widgets/app_snackbar.dart';
import '../../../../common/widgets/circular_image.dart';
import '../../../ride/presentation/screens/ride_screen.dart';
import '../../../ride/presentation/screens/odometer_camera_screen.dart';
import '../../../vehicle/domain/entities/vehicle_entiry.dart';
import '../../../vehicle/presentation/bloc/vehicle_bloc.dart';
import '../../../vehicle/presentation/bloc/vehicle_event.dart';
import '../../../vehicle/presentation/bloc/vehicle_state.dart';

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

  final PageController _pageController = PageController(viewportFraction: 0.5);
  int _currentIndex = 0;
  bool _isRideStarting = false;

  final double _mapPaddingBottom = 250.0;
  bool _showInstruction = true;
  
  // Instruction cycling variables
  int _currentInstructionIndex = 0;
  bool _isAutoCycling = true;
  
  // List of instructions
  final List<Map<String, dynamic>> _instructions = [
    {
      'title': 'Select Vehicle',
      'description': 'Choose your vehicle from the list below to start your ride',
      'icon': Icons.motorcycle,
    },
    {
      'title': 'Capture Odometer',
      'description': 'Take a photo of your odometer reading before starting the ride',
      'icon': Icons.camera_alt,
    },
    {
      'title': 'Start Your Ride',
      'description': 'Tap the "Start Ride" button to begin tracking your journey',
      'icon': Icons.play_arrow,
    },
    {
      'title': 'Safety First',
      'description': 'Ensure you have all necessary safety gear before riding',
      'icon': Icons.safety_check,
    },
    {
      'title': 'Check Location',
      'description': 'Make sure your location is accurate on the map',
      'icon': Icons.location_on,
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startInstructionCycling();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
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
    if (_currentLocation != null) _animateToCurrentLocation();
  }

  void _startInstructionCycling() {
    if (_isAutoCycling) {
      _cycleInstructions();
    }
  }

  void _cycleInstructions() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _isAutoCycling && _showInstruction) {
        setState(() {
          _currentInstructionIndex = (_currentInstructionIndex + 1) % _instructions.length;
        });
        _cycleInstructions(); // Continue cycling
      }
    });
  }

  void _nextInstruction() {
    if (_currentInstructionIndex < _instructions.length - 1) {
      setState(() {
        _currentInstructionIndex++;
        _isAutoCycling = false; // Stop auto-cycling when user manually navigates
      });
    }
  }

  void _previousInstruction() {
    if (_currentInstructionIndex > 0) {
      setState(() {
        _currentInstructionIndex--;
        _isAutoCycling = false; // Stop auto-cycling when user manually navigates
      });
    }
  }

  Future<void> _startRide(List<VehicleEntity> vehicles) async {
    try {
      setState(() => _isRideStarting = true);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          AppSnackBar.error(context, 'Please sign in to start a ride');
        }
        return;
      }

      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        if (mounted) {
          AppSnackBar.error(
            context,
            'Unable to get location. Please check permissions.',
          );
        }
        return;
      }

      final selectedVehicle = vehicles[_currentIndex];
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideScreen(
              selectedVechile: selectedVehicle,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error starting ride: $e');
    }}
  }

  Future<void> _navigateToOdometerCamera(List<VehicleEntity> vehicles) async {
    try {
      if (vehicles.isEmpty) {
        if (mounted) {
          AppSnackBar.error(context, 'No vehicles available');
        }
        return;
      }

      final selectedVehicle = vehicles[_currentIndex];
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OdometerCameraScreen(
              selectedVehicle: selectedVehicle,
              odometerType: OdometerType.beforeRide,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error navigating to camera: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(0, 0),
                    zoom: 15.0,
                  ),
                  padding: EdgeInsets.only(bottom: _mapPaddingBottom),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                _buildTopButtons(),
                _buildBottomSheet(),
                if (_showInstruction) _buildFloatingInstruction(),
              ],
            ),
    );
  }

  Widget _buildFloatingInstruction() {
    final currentInstruction = _instructions[_currentInstructionIndex];
    
    return Positioned(
      bottom: _mapPaddingBottom + 120, // Position above bottom sheet with 20px spacing
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: _showInstruction ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        child: AnimatedSlide(
          offset: _showInstruction ? Offset.zero : const Offset(0, -0.5),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with instruction icon and title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          currentInstruction['icon'] as IconData,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentInstruction['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentInstruction['description'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showInstruction = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Navigation controls and progress indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      GestureDetector(
                        onTap: _currentInstructionIndex > 0 ? _previousInstruction : null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _currentInstructionIndex > 0 
                                ? Colors.white.withOpacity(0.2) 
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: _currentInstructionIndex > 0 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.5),
                            size: 16,
                          ),
                        ),
                      ),
                      
                      // Progress indicator
                      Row(
                        children: List.generate(_instructions.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == _currentInstructionIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          );
                        }),
                      ),
                      
                      // Next button
                      GestureDetector(
                        onTap: _currentInstructionIndex < _instructions.length - 1 
                            ? _nextInstruction 
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _currentInstructionIndex < _instructions.length - 1 
                                ? Colors.white.withOpacity(0.2) 
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: _currentInstructionIndex < _instructions.length - 1 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.5),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopButtons() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.white.withOpacity(0.8),
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Material(
            color: Colors.white.withOpacity(0.8),
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              icon: const Icon(Icons.my_location, color: Colors.black),
              onPressed: _animateToCurrentLocation,
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 16),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: BlocProvider(
        create: (context) => sl<VehicleBloc>()
          ..add(LoadUserVehicles(FirebaseAuth.instance.currentUser?.uid ?? '')),
        child: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (context, state) {
            if (state is VehicleLoading) return _loadingVehicles();
            if (state is VehicleError) return _errorVehicles();
            if (state is VehicleLoaded && state.vehicles.isEmpty)
              return _noVehicles();
            if (state is VehicleLoaded) return _vehicleSelector(state.vehicles);
            return _loadingVehicles();
          },
        ),
      ),
    );
  }

  Widget _loadingVehicles() => _bottomContainer(
    child: const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  Widget _errorVehicles() => _bottomContainer(
    child: const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('Error loading vehicles')),
    ),
  );

  Widget _noVehicles() => _bottomContainer(
    child: const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: Text('No vehicles found. Please add a vehicle.')),
    ),
  );
  Widget _vehicleSelector(List<VehicleEntity> vehicles) {
    return _bottomContainer(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Text(
              'Select Vehicle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Arrow indicator
            const Icon(Icons.arrow_drop_down, size: 24, color: Colors.black54),
            const SizedBox(height: 12),

            // Animated vehicle switcher
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: vehicles.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double scale = 1.0;
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        final page =
                            _pageController.page ?? _currentIndex.toDouble();
                        final diff = (index - page).abs();
                        scale = 1.0 - (diff * 0.4);
                        if (scale < 0.6) scale = 0.6;
                      } else {
                        scale = index == _currentIndex ? 1.0 : 0.7;
                      }

                      final normalized = ((scale - 0.6) / 0.4).clamp(0.0, 1.0);
                      const double minSize = 60.0;
                      const double maxSize = 110.0;
                      final size = minSize + (maxSize - minSize) * normalized;
                      final fontSize = 11.0 + (14.0 - 11.0) * normalized;
                      final textColor = Theme.of(context).colorScheme.onSurface
                          .withOpacity(0.7 + 0.3 * normalized);

                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 140),
                            curve: Curves.easeOutCubic,
                          );
                          setState(() => _currentIndex = index);
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOutCubic,
                              width: size,
                              height: size,
                              child: CircularImage(
                                imageUrl: vehicles[index].vehicleBrandImage,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${vehicles[index].vehicleBrandName} ${vehicles[index].vehicleModelName}',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: index == _currentIndex
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              )
            ),

            const SizedBox(height: 20),
            // Odometer and Start Ride Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildCustomOutlinedButton(
                      text: 'Capture Odometer',
                      onPressed: () {
                        _navigateToOdometerCamera(vehicles);
                      },
                      icon: Icons.camera_alt,
                      borderColor: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCustomButton(
                      text: _isRideStarting ? 'Starting...' : 'Start Ride',
                      onPressed: () {
                        _startRide(vehicles);
                      },
                      icon: Icons.motorcycle,
                      backgroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            
          ],
        ),
      ),
    );
  }

  Widget _bottomContainer({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: IntrinsicHeight(child: child),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage ?? 'Error'),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
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
        minimumSize: const Size(0, 48), // Only set height, let width be flexible
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
        minimumSize: const Size(0, 48), // Only set height, let width be flexible
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

  @override
  void dispose() {
    _mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

extension _PaddingX on Widget {
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );
}


