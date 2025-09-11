import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/custome_divider.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/ride_details_screen.dart';
import '../../ride/presentation/bloc/ride_bloc.dart';
import '../../ride/presentation/bloc/ride_event.dart';
import '../../ride/domain/entities/ride_entity.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/widgets/ride_card_widget.dart';

class HomeRecentRide extends StatelessWidget {
  final List<RideEntity> remoteRides;
  final List<RideEntity> localRides;

  const HomeRecentRide({
    super.key,
    this.remoteRides = const [],
    this.localRides = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Combine remote and local rides, removing duplicates
    final allRides = <RideEntity>[];
    final seenIds = <String>{};
    
    // Add remote rides first
    for (final ride in remoteRides) {
      if (!seenIds.contains(ride.id)) {
        allRides.add(ride);
        seenIds.add(ride.id);
      }
    }
    
    // Add local rides that aren't already uploaded
    for (final ride in localRides) {
      if (!seenIds.contains(ride.id)) {
        allRides.add(ride);
        seenIds.add(ride.id);
      }
    }
    
    // Sort by start date (most recent first) and limit to 1
    allRides.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final recentRides = allRides.take(1).toList();

    if (recentRides.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const CustomeDivider(text: 'Recent Rides'),
        const SizedBox(height: 16),
        _buildRecentRidesList(context, theme, recentRides, remoteRides),
      ],
    );
  }
  

  Widget _buildRecentRidesList(BuildContext context, ThemeData theme, List<RideEntity> rides, List<RideEntity> remoteRides) {
    return Column(
      children: rides.map((ride) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildRideCard(context, ride, remoteRides),
      )).toList(),
    );
  }

  Widget _buildRideCard(BuildContext context, RideEntity ride, List<RideEntity> remoteRides) {
    final isLocal = !remoteRides.any((remoteRide) => remoteRide.id == ride.id);
    
    return Stack(
      children: [
        RideCardWidget(
          ride: ride,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RideDetailsScreen(ride: ride)),
            );
          },
          icon: Icons.directions_bike_outlined,
          iconColor: isLocal ? Colors.orange : Colors.blue,
          iconBackgroundColor: isLocal 
              ? Colors.orange.withValues(alpha: 0.1)
              : Colors.blue.withValues(alpha: 0.1),
        ),
        // Upload button for local rides
        if (isLocal)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.cloud_upload, size: 20),
                color: Colors.orange,
                onPressed: () => _uploadRide(context, ride),
                tooltip: 'Upload ride',
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        // Local ride indicator
        if (isLocal)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LOCAL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _uploadRide(BuildContext context, RideEntity ride) {
    context.read<RideBloc>().add(UploadRideEvent(rideEntity: ride));
  }

}
