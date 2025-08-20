import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:uuid/uuid.dart';

import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/ride_screen.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart';

class SelectVehicleForRiderBottomSheet extends StatefulWidget {
  final List<Map<String, String>> vehicles;
  final Function(int)? onVehicleSelected;

  const SelectVehicleForRiderBottomSheet({
    super.key,
    required this.vehicles,
    this.onVehicleSelected,
  });

  @override
  State<SelectVehicleForRiderBottomSheet> createState() =>
      _SelectVehicleForRiderBottomSheetState();
}

class _SelectVehicleForRiderBottomSheetState
    extends State<SelectVehicleForRiderBottomSheet> {
  late PageController _pageController;
  int _currentIndex = 0;
  final LocationService _locationService = LocationService();
  bool _isLoading = false;

  final List<Map<String, String>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _vehicles.addAll(widget.vehicles);
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.5,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Return the current selected index when bottom sheet is disposed
    super.dispose();
  }

  void _animateToPage(int index) {
    if (index >= 0 && index < _vehicles.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
      );
      // Call the callback when a vehicle is selected
      widget.onVehicleSelected?.call(index);
    }
  }

  Future<void> _startRide() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          AppSnackBar.showSnackBar(context, 'Please sign in to start a ride');
        }
        return;
      }

      // Get current location
      final position = await _locationService.getCurrentPosition();
      if (position == null) {
        if (mounted) {
         AppSnackBar.error(context,  'Unable to get location. Please check permissions.');
        }
        return;
      }

      // Get selected vehicle ID using brand name and model name
      final selectedVehicle = _vehicles[_currentIndex];

      // Create RideEntity
      final rideEntity = RideEntity(
        id: const Uuid().v4(), // Generate a unique id for the ride
        userId: currentUser.uid,
        vehicleId: selectedVehicle['id']!,
        status: 'active',
        startedAt: DateTime.now(),
        startCoordinates: GeoPoint(position.latitude, position.longitude),
      );

      // Dispatch StartRideEvent through RideBloc
      final rideBloc = sl<RideBloc>();
      rideBloc.add(StartRideEvent(rideEntity: rideEntity));
      
      if (mounted) {
        // Navigate to ride screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideScreen(
              rideEntity: rideEntity,
              selectedVechile: _vehicles[_currentIndex],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting ride: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
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
      child: Column(
        children: [
          // Divider handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Vehicle selection header
                Text(
                  'Select Vehicle',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Swipe to change vehicle',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),

                // Arrow indicator pointing to selected vehicle (simple icon for stability)
                Icon(
                  Icons.arrow_drop_down,
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 12),

                // Horizontal scrollable vehicle list with center selection
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _pageController,
                    padEnds: true,
                    itemCount: _vehicles.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                      // Notify parent so it can update the marker when user swipes
                      widget.onVehicleSelected?.call(index);
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double scale;
                          if (_pageController.hasClients &&
                              _pageController.position.haveDimensions) {
                            final double page =
                                _pageController.page ??
                                _currentIndex.toDouble();
                            final double diff = (index - page).abs();
                            // 1.0 for center, down to ~0.6 for far items
                            scale = 1.0 - (diff * 0.4);
                            if (scale < 0.6) scale = 0.6;
                          } else {
                            scale = index == _currentIndex ? 1.0 : 0.7;
                          }

                          final double normalized = ((scale - 0.6) / 0.4)
                              .clamp(0.0, 1.0);
                          const double minSize = 60.0;
                          const double maxSize = 110.0;
                          final double size =
                              minSize + (maxSize - minSize) * normalized;
                          final double fontSize =
                              11.0 + (14.0 - 11.0) * normalized;
                          final Color textColor = Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7 + 0.3 * normalized);

                          return GestureDetector(
                            onTap: () {
                              _animateToPage(index);
                              // Also call the callback directly on tap for immediate response
                              widget.onVehicleSelected?.call(index);
                            },
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 120),
                                  curve: Curves.easeOutCubic,
                                  width: size,
                                  height: size,
                                  child: CircularImage(
                                    imageUrl: _vehicles[index]['image']!,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                    Text(
                                      '${_vehicles[index]['brandName']} ${_vehicles[index]['modelName']}',
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
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: 200,
                  child: PrimaryButton(
                    text: _isLoading ? 'Starting...' : 'Start Ride',
                    onPressed: _isLoading ? () {} : () => _startRide(),
                    icon: Icons.motorcycle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
