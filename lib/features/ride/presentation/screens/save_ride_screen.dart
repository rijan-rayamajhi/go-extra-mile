import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/main/main_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_gem_coin_section.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_ride_odometer_card.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_ride_performance_widget.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_ride_memory_widget.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_ride_details_form_widget.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/address_card_widget.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/vehicle_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

LatLng geoPointToLatLng(GeoPoint point) =>
    LatLng(point.latitude, point.longitude);

class SaveRideScreen extends StatefulWidget {
  const SaveRideScreen({super.key});

  @override
  State<SaveRideScreen> createState() => _SaveRideScreenState();
}

class _SaveRideScreenState extends State<SaveRideScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _hasNavigated = false; // Add navigation guard

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard Ride?'),
        content: const Text(
          'Are you sure you want to discard this ride? All data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Reset ride and navigate
              context.read<RideBloc>().add(ResetRide());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard Ride'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Save Ride'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => _showDiscardDialog(context),
            icon: const Icon(Icons.close),
          ),
        ),
        body: BlocConsumer<RideBloc, RideState>(
          listener: (context, state) {},
          builder: (context, state) {
            final ride = state.currentRide;

            if (ride == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(baseScreenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (ride.vehicleId != null)
                      VehicleCardWidget(vehicleId: ride.vehicleId!),
                    const SizedBox(height: 12),
                    // Ride performance
                    RidePerformanceWidget(
                      totalDistance: ride.totalDistance ?? 0.0,
                      totalDuration: Duration(
                        seconds: (ride.totalTime ?? 0).toInt(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Start and End Addresses
                    if (ride.startCoordinates != null ||
                        ride.endCoordinates != null)
                      AddressCard(
                        startCoordinates: ride.startCoordinates,
                        endCoordinates: ride.endCoordinates,
                      ),
                    const SizedBox(height: 12),

                    // Ride Memories
                    if (ride.rideMemories != null &&
                        ride.rideMemories!.isNotEmpty &&
                        ride.startCoordinates != null &&
                        ride.endCoordinates != null) ...[
                      RideMemoryWidget(
                        startCoordinate: ride.startCoordinates!,
                        endCoordinate: ride.endCoordinates!,
                        rideMemories: ride.rideMemories!,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Odometer - Always show to display missing readings warning
                    OdometerCard(
                      beforeImage: ride.odometer?.beforeRideOdometerImage,
                      beforeCaptureTime:
                          ride.odometer?.beforeRideOdometerImageCaptureAt ??
                          DateTime.now(),
                      afterImage: ride.odometer?.afterRideOdometerImage,
                      afterCaptureTime:
                          ride.odometer?.afterRideOdometerImageCaptureAt ??
                          DateTime.now(),
                      verificationStatus: ride.odometer?.verificationStatus,
                    ),
                    const SizedBox(height: 12),

                    // Ride Details Form
                    RideDetailsForm(
                      formKey: _formKey,
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      isPublic: _isPublic,
                      onPrivacyChanged: (value) {
                        setState(() => _isPublic = value);
                      },
                    ),
                    const SizedBox(height: 12),

                    // GEM Coins
                    GemCoinsSection(
                      totalGemCoins: ride.totalGEMCoins ?? 0.0,
                      totalDistance: ride.totalDistance ?? 0.0,
                    ),
                    const SizedBox(height: 12),

                    BlocConsumer<RideDataBloc, RideDataState>(
                      listener: (context, state) {
                        if (state is RideDataLoaded && !_hasNavigated) {
                          // Set navigation guard to prevent multiple navigations
                          _hasNavigated = true;

                          // Show success message
                          AppSnackBar.info(context, 'Ride saved successfully!');

                          // Reset ride and navigate to main screen
                          context.read<RideBloc>().add(ResetRide());
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                            (route) => false,
                          );
                        } else if (state is RideDataError && !_hasNavigated) {
                          AppSnackBar.error(context, 'Failed to save ride');
                        }
                      },
                      builder: (context, state) {
                        if (state is RideDataLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return PrimaryButton(
                          text: 'Save Ride',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Copy ride with title, description, and public status
                              final updatedRide = ride.copyWith(
                                rideTitle: _titleController.text,
                                rideDescription: _descriptionController.text,
                                isPublic: _isPublic,
                              );

                              context.read<RideDataBloc>().add(
                                UploadRideEvent(updatedRide),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
