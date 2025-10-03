import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/app_stats_bloc.dart';
import 'presentation/bloc/app_stats_event.dart';
import 'presentation/bloc/app_stats_state.dart';

class HomeAppStatsWidget extends StatefulWidget {
  const HomeAppStatsWidget({super.key});

  @override
  State<HomeAppStatsWidget> createState() => _HomeAppStatsWidgetState();
}

class _HomeAppStatsWidgetState extends State<HomeAppStatsWidget> {
  @override
  void initState() {
    super.initState();
    // Load app stats when widget initializes
    context.read<AppStatsBloc>().add(const LoadAppStats());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'So far our GEM Riders have',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BlocBuilder<AppStatsBloc, AppStatsState>(
            builder: (context, state) {
              if (state is AppStatsLoading) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is AppStatsError) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load statistics',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AppStatsBloc>().add(
                            const LoadAppStats(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is AppStatsLoaded) {
                final stats = state.appStats;
                return Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                      _buildStatCard(
                        context,
                        'GEM Coins',
                        _formatNumber(stats.totalGemCoins),
                        'EARNED',
                      ),
                      const SizedBox(width: 32),
                      _buildStatCard(
                        context,
                        'Distance',
                        _formatDistance(stats.totalDistance),
                        'KMs',
                      ),
                      const SizedBox(width: 32),
                      _buildStatCard(
                        context,
                        'Rides',
                        _formatNumber(stats.totalRides),
                        'COMPLETED',
                      ),
                    ],
                    ),
                  ),
                );
              }

              // Initial state - show loading
              return const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    String suffix,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.blue),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 9),
              child: Text(
                suffix,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatDistance(double distance) {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}K';
    }
    return distance.toStringAsFixed(1);
  }
}
