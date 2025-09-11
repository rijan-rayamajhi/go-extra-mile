import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vehicle_details_screen.dart';

class MyVehicleGridViewWidget extends StatelessWidget {
  final List<VehicleEntity> vehicles;
  const MyVehicleGridViewWidget({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...vehicles.map((vehicle) => PremiumVehicleCard(vehicle: vehicle)),
      ],
    );
  }
}

class PremiumVehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;

  const PremiumVehicleCard({super.key, required this.vehicle});

  IconData _getStatusIcon() {
    switch (vehicle.verificationStatus) {
      case VehicleVerificationStatus.verified:
        return Icons.check_circle;
      case VehicleVerificationStatus.pending:
        return Icons.schedule;
      case VehicleVerificationStatus.rejected:
        return Icons.cancel;
      case VehicleVerificationStatus.notVerified:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor() {
    switch (vehicle.verificationStatus) {
      case VehicleVerificationStatus.verified:
        return Colors.green;
      case VehicleVerificationStatus.pending:
        return Colors.orange;
      case VehicleVerificationStatus.rejected:
        return Colors.red;
      case VehicleVerificationStatus.notVerified:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyVehicleDetailsScreen(vehicleId: vehicle.id),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 16 / 12,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Blurred background image
                if (vehicle.vehicleBrandImage.isNotEmpty)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: vehicle.vehicleSlideImages?.isNotEmpty ?? false
                              ? CachedNetworkImageProvider(
                                  vehicle.vehicleSlideImages?.first ?? vehicle.vehicleBrandImage,
                                )
                              : CachedNetworkImageProvider(
                                  vehicle.vehicleBrandImage,
                                ),

                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey.shade400, Colors.grey.shade600],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                          Text(
                            'Add Vehicle Image',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Dark overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(screenPadding),
                  child: Stack(
                    children: [
                      // Brand logo + status badge
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: CachedNetworkImageProvider(
                                vehicle.vehicleBrandImage,
                              ),
                              backgroundColor: Colors.white,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getStatusIcon(),
                                  color: _getStatusColor(),
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Brand + Model
                      Positioned(
                        top: 0,
                        left: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.vehicleBrandName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.white, // White for contrast
                              ),
                            ),
                            Text(
                              vehicle.vehicleModelName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade200, // Light text
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom Left: Reg No
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Text(
                          vehicle.vehicleRegistrationNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      // Bottom Right: Action
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "View Details",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
