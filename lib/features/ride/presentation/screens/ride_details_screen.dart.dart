import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_gem_coin_section.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_ride_odometer_card.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_ride_performance_widget.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_ride_memory_widget.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/address_card_widget.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/vehicle_card.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class RideDetailsScreen extends StatelessWidget {
  final RideEntity ride;

  const RideDetailsScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ride.rideTitle ?? 'Ride Details'),
        actions: [
          IconButton(
            onPressed: () => _shareRide(),
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(baseScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Card
              if (ride.vehicleId != null)
                VehicleCardWidget(vehicleId: ride.vehicleId!),
              const SizedBox(height: 12),

              // Ride Performance
              RidePerformanceWidget(
                totalDistance: ride.totalDistance ?? 0.0,
                totalDuration: Duration(seconds: (ride.totalTime ?? 0).toInt()),
              ),
              const SizedBox(height: 12),

              // Route Details
              if (ride.startCoordinates != null || ride.endCoordinates != null)
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

              // Ride Details (Title & Description)
              if (ride.rideTitle != null || ride.rideDescription != null) ...[
                _buildRideDetailsCard(context),
                const SizedBox(height: 12),
              ],

              // GEM Coins
              GemCoinsSection(
                totalGemCoins: ride.totalGEMCoins ?? 0.0,
                totalDistance: ride.totalDistance ?? 0.0,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  void _shareRide() {
    final distance = (ride.totalDistance ?? 0) / 1000;
    final duration = Duration(seconds: (ride.totalTime ?? 0).toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    String durationText;
    if (hours > 0) {
      durationText = '${hours}h ${minutes}m';
    } else {
      durationText = '${minutes}m';
    }

    final gemCoins = ride.totalGEMCoins?.toStringAsFixed(0) ?? '0';
    final title = ride.rideTitle ?? 'My Ride';

    String shareText = '🚴 $title\n\n';
    shareText += '📍 Distance: ${distance.toStringAsFixed(2)} km\n';
    shareText += '⏱️ Duration: $durationText\n';
    shareText += '💎 GEM Coins: $gemCoins\n';

    if (ride.rideDescription != null && ride.rideDescription!.isNotEmpty) {
      shareText += '\n📝 ${ride.rideDescription}\n';
    }

    if (ride.endedAt != null) {
      final formattedDate = DateFormat('MMM dd, yyyy').format(ride.endedAt!);
      shareText += '\n📅 $formattedDate\n';
    }

    shareText += '\nShared from Go Extra Mile 🚴‍♂️';

    Share.share(shareText, subject: title);
  }

  Widget _buildRideDetailsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ride Details",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          if (ride.rideTitle != null) ...[
            Text(
              "Title",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ride.rideTitle!,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 12),
          ],

          if (ride.rideDescription != null &&
              ride.rideDescription!.trim().isNotEmpty) ...[
            Text(
              "Description",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ride.rideDescription!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Icon(
                ride.isPublic == true ? Icons.public : Icons.lock,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                ride.isPublic == true ? "Public Ride" : "Private Ride",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
