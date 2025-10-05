import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/ride_details_screen.dart.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_card.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/recent_ride_card_shimmer.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:intl/intl.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

class MyRideScreen extends StatefulWidget {
  const MyRideScreen({super.key});

  @override
  State<MyRideScreen> createState() => _MyRideScreenState();
}

class _MyRideScreenState extends State<MyRideScreen> {
  String? _selectedVehicleId; // null means "All Rides"

  @override
  void initState() {
    super.initState();
    // Load rides when screen initializes
    context.read<RideDataBloc>().add(const LoadAllRides());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<RideDataBloc, RideDataState>(
        builder: (context, state) {
          if (state is RideDataLoading) {
            return _buildLoadingState();
          } else if (state is RideDataError) {
            return _buildErrorState(state.message);
          } else if (state is RideDataLoaded) {
            // Track which rides are local for upload functionality
            final localRideIds = <String>{};
            for (var ride in (state.localRides ?? [])) {
              if (ride.id != null) {
                localRideIds.add(ride.id!);
              }
            }

            // Combine local and remote rides
            final allRides = [
              ...(state.localRides ?? []),
              ...(state.remoteRides ?? []),
            ];

            // Remove duplicates based on ride id (prefer remote over local)
            final uniqueRides = <String, RideEntity>{};
            for (var ride in allRides) {
              if (ride.id != null) {
                // If we already have this ride and current is from remote, keep remote
                if (uniqueRides.containsKey(ride.id!) && !localRideIds.contains(ride.id!)) {
                  continue; // Keep the remote version
                }
                uniqueRides[ride.id!] = ride;
              }
            }

            final rides = uniqueRides.values.toList();

            // Sort by endedAt date (most recent first)
            rides.sort((a, b) {
              if (a.endedAt == null && b.endedAt == null) return 0;
              if (a.endedAt == null) return 1;
              if (b.endedAt == null) return -1;
              return b.endedAt!.compareTo(a.endedAt!);
            });

            // Filter rides by selected vehicle
            final filteredRides = _selectedVehicleId == null
                ? rides
                : rides
                      .where((ride) => ride.vehicleId == _selectedVehicleId)
                      .toList();

            if (rides.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<RideDataBloc>().add(const LoadAllRides());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(baseScreenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Rides',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${filteredRides.length} ${filteredRides.length == 1 ? 'ride' : 'rides'}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Filter Chips
                      _buildVehicleFilterChips(rides),
                      const SizedBox(height: 20),

                      // Show empty state if filtered rides is empty
                      if (filteredRides.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              'No rides found for this vehicle',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        )
                      else
                        ..._buildGroupedRides(filteredRides, localRideIds),
                    ],
                  ),
                ),
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  List<Widget> _buildGroupedRides(List<RideEntity> rides, Set<String> localRideIds) {
    // Group rides by month and year
    final Map<String, List<RideEntity>> groupedRides = {};

    for (var ride in rides) {
      if (ride.endedAt != null) {
        final monthYear = DateFormat('MMMM yyyy').format(ride.endedAt!);
        if (!groupedRides.containsKey(monthYear)) {
          groupedRides[monthYear] = [];
        }
        groupedRides[monthYear]!.add(ride);
      }
    }

    // Sort month keys in descending order (most recent first)
    final sortedKeys = groupedRides.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    // Build widgets for each month group
    final List<Widget> widgets = [];
    for (var monthYear in sortedKeys) {
      final monthRides = groupedRides[monthYear]!;

      // Month header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: Text(
            monthYear,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      );

      // Rides for this month
      for (var ride in monthRides) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildRideCardWithUpload(context, ride, localRideIds),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildVehicleFilterChips(List rides) {
    // Get unique vehicle IDs from rides
    final vehicleIds = rides
        .where((ride) => ride.vehicleId != null)
        .map((ride) => ride.vehicleId as String)
        .toSet()
        .toList();

    if (vehicleIds.isEmpty) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, vehicleState) {
        if (vehicleState is! VehicleLoaded) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // "All Rides" chip
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All Rides'),
                  selected: _selectedVehicleId == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedVehicleId = null;
                    });
                  },
                  avatar: Icon(
                    Icons.directions_bike,
                    size: 18,
                    color: _selectedVehicleId == null
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Colors.grey.shade700,
                  ),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: _selectedVehicleId == null
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Colors.grey.shade700,
                    fontWeight: _selectedVehicleId == null
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: _selectedVehicleId == null
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    width: _selectedVehicleId == null ? 1.5 : 1,
                  ),
                  showCheckmark: false,
                ),
              ),
              // Vehicle chips
              ...vehicleIds.map((vehicleId) {
                // Find vehicle by ID
                final vehicleIndex = vehicleState.vehicles.indexWhere(
                  (v) => v.id == vehicleId,
                );

                // Skip if vehicle not found
                if (vehicleIndex == -1) {
                  return const SizedBox.shrink();
                }

                final vehicle = vehicleState.vehicles[vehicleIndex];
                final isSelected = _selectedVehicleId == vehicleId;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(vehicle.vehicleBrandName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedVehicleId = selected ? vehicleId : null;
                      });
                    },
                    avatar: CircleAvatar(
                      radius: 16,
                      backgroundImage: CachedNetworkImageProvider(
                        vehicle.vehicleBrandImage,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Colors.grey.shade700,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                    showCheckmark: false,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(baseScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Rides',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: RecentRideCardShimmer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(baseScreenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading rides',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<RideDataBloc>().add(const LoadAllRides());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(baseScreenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_bike, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No rides yet',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your first ride to see it here!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRideCardWithUpload(BuildContext context, RideEntity ride, Set<String> localRideIds) {
    final isLocalRide = ride.id != null && localRideIds.contains(ride.id!);
    
    return Stack(
      children: [
        RideCard(
          ride: ride,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RideDetailsScreen(ride: ride),
              ),
            );
          },
        ),
        // Upload icon for local rides
        if (isLocalRide)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _uploadLocalRide(context, ride),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.orange.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _uploadLocalRide(BuildContext context, RideEntity ride) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Ride'),
        content: const Text(
          'This will upload your local ride to the cloud and remove it from local storage. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performUpload(context, ride);
            },
            child: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _performUpload(BuildContext context, RideEntity ride) {
    // Dispatch upload event to RideDataBloc
    context.read<RideDataBloc>().add(UploadRideEvent(ride));
    
    // Show success message
    AppSnackBar.success(context, 'Ride uploaded successfully!');
  }
}
