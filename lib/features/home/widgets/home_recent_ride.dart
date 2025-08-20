import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/custome_divider.dart';
import 'package:intl/intl.dart';
import '../../ride/presentation/bloc/ride_bloc.dart';
import '../../ride/presentation/bloc/ride_event.dart';
import '../../ride/presentation/bloc/ride_state.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../ride/domain/entities/ride_entity.dart';
import 'package:shimmer/shimmer.dart';

class HomeRecentRide extends StatefulWidget {
  const HomeRecentRide({super.key});

  @override
  State<HomeRecentRide> createState() => _HomeRecentRideState();
}

class _HomeRecentRideState extends State<HomeRecentRide> {
  @override
  void initState() {
    super.initState();
    // Fetch recent rides when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRecentRides();
    });
  }

  void _fetchRecentRides() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<RideBloc>().add(
        GetRecentRidesByUserIdEvent(
          userId: authState.user.uid,
          limit: 3, // Get the 3 most recent rides
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const SizedBox.shrink(); // Don't show if not authenticated
        }

        return BlocBuilder<RideBloc, RideState>(
          builder: (context, rideState) {
            if (rideState is RideLoading) {
              return _buildLoadingCard(theme);
            } else if (rideState is RecentRidesLoaded && rideState.rides.isNotEmpty) {
              return Column(
                children: [
                  CustomeDivider(text: 'Recent Rides'),

                  SizedBox(height: 16),
                  _buildRecentRidesList(theme, rideState.rides),
                ],
              );
            } else if (rideState is RideFailure) {
              return _buildErrorCard(theme, rideState.message);
            } else {
              // No rides available
              return SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Shimmer for ride stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShimmerStat(),
                  _divider(),
                  _buildShimmerStat(),
                  _divider(),
                  _buildShimmerStat(),
                ],
              ),
              const SizedBox(height: 16),
              // Shimmer for date text
              Container(
                width: 150,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerStat() {
    return Column(
      children: [
        Container(
          width: 30,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRidesList(ThemeData theme, List<RideEntity> rides) {
    return Column(
      children: rides.map((ride) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildRideCard(theme, ride),
      )).toList(),
    );
  }

  Widget _buildRideCard(ThemeData theme, RideEntity ride) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.directions_bike,
                      color: Colors.blue.shade700, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  "Recent Rides",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ride stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _rideStat("Distance", "${ride.totalDistance?.toStringAsFixed(1) ?? '0'} km"),
                _divider(),
                _rideStat("Time", "${ride.totalTime?.toStringAsFixed(0) ?? '0'} min"),
                _divider(),
                _rideStat("Coins", "${ride.totalGEMCoins?.toStringAsFixed(0) ?? '0'}"),
              ],
            ),
            const SizedBox(height: 16),

            // Ride date
            Text(
              "Started • ${DateFormat('dd MMM, hh:mm a').format(ride.startedAt)}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            if (ride.endedAt != null)
              Text(
                "Ended • ${DateFormat('dd MMM, hh:mm a').format(ride.endedAt!)}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String errorMessage) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.red.shade300,
          width: 1.2,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.error_outline,
                      color: Colors.red.shade700, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  "Error Loading Ride",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _fetchRecentRides,
                child: const Text("Retry"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRidesCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.grey.shade300,
          width: 1.2,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.directions_bike,
                      color: Colors.grey.shade600, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  "No Rides Yet",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Start your first ride to see your stats here!",
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rideStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}
