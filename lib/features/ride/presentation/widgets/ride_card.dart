import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

class RideCard extends StatelessWidget {
  final RideEntity ride;
  final VoidCallback? onTap;

  const RideCard({super.key, required this.ride, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Ride Title and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ride.rideTitle ?? "Recent Ride",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getTimeAgo(ride.endedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// Ride Stats Inline
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    icon: Icons.map,
                    value:
                        "${((ride.totalDistance ?? 0) / 1000).toStringAsFixed(2)} km",
                    label: "Distance",
                    theme: theme,
                  ),
                  _divider(),
                  _buildStatColumn(
                    icon: Icons.access_time,
                    value: _formatTime(ride.totalTime),
                    label: "Time",
                    theme: theme,
                  ),
                  _divider(),
                  _buildStatColumn(
                    icon: Icons.monetization_on,
                    value: "${(ride.totalGEMCoins ?? 0).toStringAsFixed(2)}",
                    label: "GEM Coins",
                    theme: theme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 22, color: Colors.blueAccent),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade200);
  }

  String _formatTime(double? totalTimeInSeconds) {
    if (totalTimeInSeconds == null || totalTimeInSeconds == 0) {
      return '0 min';
    }
    final minutes = (totalTimeInSeconds / 60).floor();
    final seconds = (totalTimeInSeconds % 60).floor();

    if (minutes == 0) {
      return '${seconds}s';
    } else if (seconds == 0) {
      return '${minutes} min';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }

  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }
}
