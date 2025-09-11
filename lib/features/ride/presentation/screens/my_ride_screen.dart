import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/ride_details_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/repositories/vehicle_repository.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart';
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
  List<VehicleEntity> _vehicles = [];
  String? _selectedVehicleId;
  List<RideEntity> _allRides = [];
  List<RideEntity> _filteredRides = [];
  bool _isLoadingVehicles = false;

  @override
  void initState() {
    super.initState();
    _loadRides();
    _loadVehicles();
  }

  void _loadRides() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<RideBloc>().add(
        GetAllRidesByUserIdEvent(userId: currentUser.uid),
      );
    }
  }

  Future<void> _loadVehicles() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoadingVehicles = true;
    });

    try {
      final vehicleRepository = sl<VehicleRepository>();
      final result = await vehicleRepository.getUserVehicles(currentUser.uid);
      
      result.fold(
        (exception) {
          // Handle error silently for now
          setState(() {
            _isLoadingVehicles = false;
          });
        },
        (vehicles) {
          setState(() {
            _vehicles = vehicles;
            _isLoadingVehicles = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoadingVehicles = false;
      });
    }
  }

  void _filterRidesByVehicle(String? vehicleId) {
    setState(() {
      _selectedVehicleId = vehicleId;
      if (vehicleId == null) {
        _filteredRides = List.from(_allRides);
      } else if (vehicleId == 'unknown') {
        // Filter rides with unknown vehicles (vehicles not found in the user's vehicle list)
        _filteredRides = _allRides.where((ride) {
          try {
            _vehicles.firstWhere((v) => v.id == ride.vehicleId);
            return false; // Vehicle found, not unknown
          } catch (e) {
            return true; // Vehicle not found, it's unknown
          }
        }).toList();
      } else {
        _filteredRides = _allRides.where((ride) => ride.vehicleId == vehicleId).toList();
      }
    });
  }

  void _updateRides(List<RideEntity> rides, List<RideEntity> localRides) {
    // Combine remote and local rides, removing duplicates
    final allRides = <RideEntity>[];
    final seenIds = <String>{};
    
    // Add remote rides first
    for (final ride in rides) {
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
    
    _allRides = allRides;
    _filterRidesByVehicle(_selectedVehicleId);
  }

  bool _isLocalRide(RideEntity ride, List<RideEntity> remoteRides) {
    return !remoteRides.any((remoteRide) => remoteRide.id == ride.id);
  }

  void _uploadRide(RideEntity ride) {
    context.read<RideBloc>().add(UploadRideEvent(rideEntity: ride));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Rides')),
      body: BlocListener<RideBloc, RideState>(
        listener: (context, state) {
          if (state is AllRidesLoaded) {
            _updateRides(state.rides, state.localRides);
          } else if (state is RideUploaded) {
            // Refresh rides after successful upload
            _loadRides();
          }
        },
        child: BlocBuilder<RideBloc, RideState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildVehicleChips(),
                  _buildRideStats(),
                  if (state is RideLoading)
                    _buildShimmerLoading()
                  else if (state is AllRidesLoaded)
                    _filteredRides.isEmpty
                        ? _buildEmptyState()
                        : _buildRidesList(_filteredRides, state.rides)
                  else if (state is RideFailure)
                    _buildErrorState(state.message)
                  else
                    const Center(child: Text('No rides found')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRideStats() {
    if (_filteredRides.isEmpty) {
      return const SizedBox.shrink();
    }

    final stats = _calculateRideStats(_filteredRides);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSimpleStatItem('Rides', stats['totalRides']!.toInt().toString()),
          _buildSimpleStatItem('Distance', '${stats['totalDistance']!.toStringAsFixed(1)} km'),
          _buildSimpleStatItem('Time', _formatDuration(stats['totalTime']!)),
          _buildSimpleStatItem('Coins', stats['totalCoins']!.toStringAsFixed(0)),
        ],
      ),
    );
  }

  Widget _buildSimpleStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyStats(List<RideEntity> monthRides) {
    final stats = _calculateRideStats(monthRides);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMonthlyStatItem('Rides', stats['totalRides']!.toInt().toString()),
          _buildMonthlyStatItem('Distance', '${stats['totalDistance']!.toStringAsFixed(1)} km'),
          _buildMonthlyStatItem('Time', _formatDuration(stats['totalTime']!)),
          _buildMonthlyStatItem('Coins', stats['totalCoins']!.toStringAsFixed(0)),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Map<String, double> _calculateRideStats(List<RideEntity> rides) {
    double totalDistance = 0;
    double totalTime = 0;
    double totalCoins = 0;
    int totalRides = rides.length;

    for (final ride in rides) {
      // Convert distance from meters to kilometers
      totalDistance += (ride.totalDistance ?? 0) / 1000;
      totalTime += ride.totalTime ?? 0;
      totalCoins += ride.totalGEMCoins ?? 0;
    }

    return {
      'totalRides': totalRides.toDouble(),
      'totalDistance': totalDistance,
      'totalTime': totalTime,
      'totalCoins': totalCoins,
    };
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)}m';
    } else {
      final hours = (minutes / 60).floor();
      final remainingMinutes = (minutes % 60).floor();
      return '${hours}h ${remainingMinutes}m';
    }
  }

  Widget _buildVehicleChips() {
    if (_isLoadingVehicles) {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get unique vehicles that have been used in rides
    final vehiclesUsedInRides = <String, VehicleEntity>{};
    bool hasUnknownVehicles = false;
    
    for (final ride in _allRides) {
      try {
        final vehicle = _vehicles.firstWhere((v) => v.id == ride.vehicleId);
        vehiclesUsedInRides[ride.vehicleId] = vehicle;
      } catch (e) {
        // If vehicle not found, mark that we have unknown vehicles
        hasUnknownVehicles = true;
      }
    }

    if (vehiclesUsedInRides.isEmpty && !hasUnknownVehicles) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
            // All rides chip
            _buildVehicleChip(
              label: 'All Rides',
              isSelected: _selectedVehicleId == null,
              onTap: () => _filterRidesByVehicle(null),
              isFirst: true,
            ),
            // Vehicle chips
            ...vehiclesUsedInRides.values.map((vehicle) => _buildVehicleChip(
              label: '${vehicle.vehicleBrandName} ${vehicle.vehicleModelName}',
              isSelected: _selectedVehicleId == vehicle.id,
              onTap: () => _filterRidesByVehicle(vehicle.id),
              brandImage: vehicle.vehicleBrandImage,
            )),
            // Other chip for rides with unknown vehicles
            if (hasUnknownVehicles)
              _buildVehicleChip(
                label: 'Other',
                isSelected: _selectedVehicleId == 'unknown',
                onTap: () => _filterRidesByVehicle('unknown'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? brandImage,
    bool isFirst = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.only(
          left: isFirst ? 0 : 8,
          right: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand image
            if (brandImage != null && brandImage.isNotEmpty)
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: NetworkImage(brandImage),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.directions_bike,
                  size: 14,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            // Vehicle name
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(6, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RideCardShimmer(),
          );
        }),
      ),
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

  Widget _buildRidesList(List<RideEntity> rides, List<RideEntity> remoteRides) {
    // Sort rides by start date (most recent first)
    final sortedRides = List<RideEntity>.from(rides)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // Group rides by month
    final Map<String, List<RideEntity>> ridesByMonth = {};
    
    for (final ride in sortedRides) {
      final monthKey = _getMonthKey(ride.startedAt);
      ridesByMonth.putIfAbsent(monthKey, () => []).add(ride);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ridesByMonth.entries.map((entry) {
          final monthKey = entry.key;
          final monthRides = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month header
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Text(
                  monthKey,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // Monthly stats
              _buildMonthlyStats(monthRides),
              // Rides for this month
              ...monthRides.map((ride) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildRideCard(ride, remoteRides),
              )),
            ],
          );
        }).toList(),
      ),
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

  Widget _buildRideCard(RideEntity ride, List<RideEntity> remoteRides) {
    final isLocal = _isLocalRide(ride, remoteRides);
    
    return Stack(
      children: [
        RideCardWidget(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RideDetailsScreen(ride: ride)),
            );
          },
          ride: ride,
          title: _getRideTitle(ride),
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
                onPressed: () => _uploadRide(ride),
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
