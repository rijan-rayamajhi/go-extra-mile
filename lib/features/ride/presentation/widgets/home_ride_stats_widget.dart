import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_state.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

class HomeRideStatsWidget extends StatefulWidget {
  const HomeRideStatsWidget({super.key});

  @override
  State<HomeRideStatsWidget> createState() => _HomeRideStatsWidgetState();
}

class _HomeRideStatsWidgetState extends State<HomeRideStatsWidget> {
  @override
  void initState() {
    super.initState();
    // Load ride data when widget initializes
    context.read<RideDataBloc>().add(const LoadAllRides());
  }

  // Calculate total distance from all rides
  double _calculateTotalDistance(List<RideEntity>? rides) {
    if (rides == null || rides.isEmpty) return 0.0;

    return rides.fold(0.0, (total, ride) {
      return total + (ride.totalDistance ?? 0.0);
    });
  }

  // Get total ride count
  int _getTotalRideCount(List<RideEntity>? rides) {
    return rides?.length ?? 0;
  }

  // Format distance in kilometers
  String _formatDistance(double distance) {
    return '${(distance / 1000).toStringAsFixed(2)} KM';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideDataBloc, RideDataState>(
      builder: (context, state) {
        if (state is RideDataLoading) {
          return _buildLoadingState(context);
        }

        if (state is RideDataError) {
          return _buildErrorState(context, state.message);
        }

        if (state is RideDataLoaded) {
          // Use remote rides (Firebase) as primary source, fallback to local rides
          final rides = state.remoteRides ?? state.localRides ?? [];
          final totalDistance = _calculateTotalDistance(rides);
          final totalRides = _getTotalRideCount(rides);

          return _buildStatsRow(context, totalDistance, totalRides);
        }

        // Default state - show zeros
        return _buildStatsRow(context, 0.0, 0);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      padding: context.padding(all: baseCardPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            context,
            icon: Icons.route,
            label: 'Total Distance',
            value: '...',
            isLoading: true,
          ),
          SizedBox(width: context.baseSpacing(baseSpacing)),
          _buildStatCard(
            context,
            icon: Icons.directions_bike,
            label: 'Total Rides',
            value: '... Rides',
            isLoading: true,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: context.padding(all: baseCardPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            context,
            icon: Icons.route,
            label: 'Total Distance',
            value: 'Error',
            isError: true,
          ),
          SizedBox(width: context.baseSpacing(baseSpacing)),
          _buildStatCard(
            context,
            icon: Icons.directions_bike,
            label: 'Total Rides',
            value: 'Error Rides',
            isError: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    double totalDistance,
    int totalRides,
  ) {
    return Container(
      padding: context.padding(horizontal: baseCardPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.route,
              label: 'Total Distance',
              value: _formatDistance(totalDistance),
            ),
          ),
          SizedBox(width: context.baseSpacing(baseSpacing)),
          Expanded(
            child: _buildStatCard(
              context,
              icon: Icons.directions_bike,
              label: 'Total Rides',
              value: '${totalRides.toString()} Rides',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon, // Keep parameter for compatibility but won't use it
    required String label,
    required String value,
    bool isLoading = false,
    bool isError = false,
  }) {
    return Container(
      padding: context.padding(all: baseCardPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.borderRadius(baseCardRadius),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isLoading)
            Row(
              children: [
                Text(
                  '$label : ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: context.fontSize(baseMediumFontSize),
                  ),
                ),
                SizedBox(
                  width: context.iconSize(baseSmallIconSize),
                  height: context.iconSize(baseSmallIconSize),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )
          else
            Expanded(
              child: Text(
                '$label : $value',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isError
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurface,
                  fontSize: context.fontSize(baseMediumFontSize),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
