import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/ride_details_screen.dart';
import '../../../../common/widgets/ride_card_widget.dart';
import '../../../../common/widgets/ride_card_shimmer.dart';
import '../bloc/ride_bloc.dart';
import '../bloc/ride_event.dart';
import '../bloc/ride_state.dart';
import '../../domain/entities/ride_entity.dart';

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({super.key});

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> {
  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  void _loadRides() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<RideBloc>().add(
        GetAllRidesByUserIdEvent(userId: currentUser.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Rides')),
      body: BlocBuilder<RideBloc, RideState>(
        builder: (context, state) {
          if (state is RideLoading) {
            return _buildShimmerLoading();
          } else if (state is AllRidesLoaded) {
            if (state.rides.isEmpty) {
              return _buildEmptyState();
            }
            return _buildRidesList(state.rides);
          } else if (state is RideFailure) {
            return _buildErrorState(state.message);
          } else {
            return const Center(child: Text('No rides found'));
          }
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6, // Show 6 shimmer cards while loading
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RideCardShimmer(),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bike_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No rides yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first ride to see it here!',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading rides',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.red.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadRides, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildRidesList(List<RideEntity> rides) {
    // Sort rides by start date (most recent first)
    final sortedRides = List<RideEntity>.from(rides)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // Group rides by month
    final Map<String, List<RideEntity>> ridesByMonth = {};
    
    for (final ride in sortedRides) {
      final monthKey = _getMonthKey(ride.startedAt);
      ridesByMonth.putIfAbsent(monthKey, () => []).add(ride);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ridesByMonth.length,
      itemBuilder: (context, index) {
        final monthKey = ridesByMonth.keys.elementAt(index);
        final monthRides = ridesByMonth[monthKey]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month header
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                monthKey,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            // Rides for this month
            ...monthRides.map((ride) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RideCardWidget(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RideDetailsScreen(ride: ride)),
                  );
                },
                ride: ride,
                title: _getRideTitle(ride),
                icon: Icons.directions_bike_outlined,
                iconColor: Colors.blue,
                iconBackgroundColor: Colors.blue.withValues(alpha: 0.1),
              ),
            )),
          ],
        );
      },
    );
  }

  String _getMonthKey(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final month = months[date.month - 1];
    final year = date.year;
    
    return '$month $year';
  }

  String _getRideTitle(RideEntity ride) {
    if (ride.rideTitle != null && ride.rideTitle!.isNotEmpty) {
      return ride.rideTitle!;
    }

    // Generate title based on status
    switch (ride.status.toLowerCase()) {
      case 'completed':
        return 'Completed Ride';
      case 'ongoing':
        return 'Ongoing Ride';
      case 'paused':
        return 'Paused Ride';
      default:
        return 'Ride';
    }
  }
}
