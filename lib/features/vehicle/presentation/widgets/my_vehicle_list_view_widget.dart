import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vehicle_details_screen.dart';


class MyVehicleListViewWidget extends StatelessWidget {
  final List<VehicleEntity> vehicles;
  const MyVehicleListViewWidget({super.key, required this.vehicles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...vehicles.map((vehicle) => _buildPremiumVehicleListViewCard(
          vehicle: vehicle,
          context: context,
        )),
      ],
    );
  }



  Widget _buildPremiumVehicleListViewCard({
    required BuildContext context,
    required VehicleEntity vehicle,
  }) {
    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyVehicleDetailsScreen(vehicleId: vehicle.id,)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.grey.shade100.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(baseScreenPadding),
          child: IntrinsicHeight(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Brand logo with badge
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundImage: CachedNetworkImageProvider(vehicle.vehicleBrandImage),
                      backgroundColor: Colors.white,
                    ),
                    if (vehicle.verificationStatus == VehicleVerificationStatus.verified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                      ),
                    if (vehicle.verificationStatus == VehicleVerificationStatus.pending)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                      ),
                    if (vehicle.verificationStatus == VehicleVerificationStatus.rejected)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    if (vehicle.verificationStatus == VehicleVerificationStatus.notVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            color: Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    // Fallback for any unexpected status
                    if (![
                      VehicleVerificationStatus.verified,
                      VehicleVerificationStatus.pending,
                      VehicleVerificationStatus.rejected,
                      VehicleVerificationStatus.notVerified,
                    ].contains(vehicle.verificationStatus))
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 20),

                // Vehicle details
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        vehicle.vehicleBrandName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.vehicleModelName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicle.vehicleRegistrationNumber,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // _buildVerificationStatusChip(verificationStatus),
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
