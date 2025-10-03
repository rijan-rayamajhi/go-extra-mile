import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/common/widgets/secondary_button.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/active_ride_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/odometer_camera_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/vehicle_selector_widget.dart';

class StartRideScreen extends StatefulWidget {
  const StartRideScreen({super.key});

  @override
  State<StartRideScreen> createState() => _StartRideScreenState();
}

class _StartRideScreenState extends State<StartRideScreen> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    context.read<RideBloc>().add(LoadInitialLocation());
  }

  void _goToCurrentLocation(LatLng target) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 15),
        ),
      );
    }
  }

  LatLng? _getCurrentCoordinates(RideState state) {
    final points = state.currentRide?.routePoints;
    if (points != null && points.isNotEmpty) {
      final last = points.last;
      return LatLng(last.latitude, last.longitude);
    }
    return state.currentRide?.startCoordinates != null
        ? LatLng(
            state.currentRide!.startCoordinates!.latitude,
            state.currentRide!.startCoordinates!.longitude,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<RideBloc, RideState>(
        listener: (context, state) {
          final current = _getCurrentCoordinates(state);
          if (current != null) _goToCurrentLocation(current);
        },
        builder: (context, state) {
          final startCoords = state.currentRide?.startCoordinates;
          if (startCoords == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(startCoords.latitude, startCoords.longitude),
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) => _mapController = controller,
                padding: const EdgeInsets.only(bottom: 200),
              ),

              // Back button
              Positioned(
                left: 16,
                child: SafeArea(
                  child: _circleButton(
                    icon: Icons.arrow_back_ios_new_outlined,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // My Location button
              Positioned(
                right: 16,
                child: SafeArea(
                  child: _circleButton(
                    icon: Icons.my_location,
                    onPressed: () =>
                        context.read<RideBloc>().add(MoveToCurrentLocation()),
                  ),
                ),
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
                        VehicleSelectorWidget(
                          onVehicleSelected: (vehicle) {
                            context.read<RideBloc>().add(
                              SelectVehicle({'vehicleId': vehicle.id}),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        if (state.currentRide?.vehicleId != null)
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
                                              isBeforeRide: true,
                                            ),
                                      ),
                                    );
                                    if (capturedImage != null) {
                                      context.read<RideBloc>().add(
                                        SaveBeforeRideOdometerImage(
                                          capturedImage['file'],
                                          capturedImage['capturedAt'],
                                        ),
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ActiveRideScreen(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: PrimaryButton(
                                  text: 'Start Ride',
                                  onPressed: () {
                                    context.read<RideBloc>().add(
                                      StartTracking(),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ActiveRideScreen(),
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
            ],
          );
        },
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
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
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: 24,
      ),
    );
  }
}
