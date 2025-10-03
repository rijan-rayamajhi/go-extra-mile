import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/common/widgets/secondary_button.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/active_ride_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/odometer_camera_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/save_ride_screen.dart';

class OdometerPreviewScreen extends StatelessWidget {
  final File imageFile;
  final bool isBeforeRide;

  const OdometerPreviewScreen({
    super.key,
    required this.imageFile,
    required this.isBeforeRide,
  });

  @override
  Widget build(BuildContext context) {
    final capturedAt = DateTime.now();

    return WillPopScope(
      onWillPop: () async => false, // prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Odometer Preview"),
          automaticallyImplyLeading: false, // remove back button
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ride Odometer",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Captured: ${capturedAt.hour.toString().padLeft(2, '0')}:${capturedAt.minute.toString().padLeft(2, '0')}:${capturedAt.second.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    "Make sure the odometer is fully visible inside the frame. This image will be used to verify your ride.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: 'Retake',
                          onPressed: () {
                            // Reopen the camera screen and replace the current preview screen
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    OdometerCameraScreen(
                                      isBeforeRide: isBeforeRide,
                                    ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Next',
                          onPressed: () {
                            final rideBloc = context.read<RideBloc>();

                            if (isBeforeRide) {
                              rideBloc.add(
                                SaveBeforeRideOdometerImage(
                                  imageFile,
                                  capturedAt,
                                ),
                              );

                              //start ride - dispatch event first
                              rideBloc.add(StartTracking());
                              
                              // Wait a frame for the event to be processed, then navigate
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  Navigator.of(context)
                                    ..pop() // Remove preview
                                    ..pop() // Remove camera
                                    ..pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => const ActiveRideScreen(),
                                      ),
                                    );
                                }
                              });
                            } else {
                              rideBloc.add(
                                SaveAfterRideOdometerImage(
                                  imageFile,
                                  capturedAt,
                                ),
                              );

                              //end ride - dispatch event first
                              rideBloc.add(StopTracking());
                              
                              // Wait a frame for the event to be processed, then navigate
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) {
                                  Navigator.of(context)
                                    ..pop() // Remove preview
                                    ..pop() // Remove camera
                                    ..push(
                                      MaterialPageRoute(
                                        builder: (_) => const SaveRideScreen(),
                                      ),
                                    );
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
