import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/screens/profile_ride_memory_details_screen.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';


class ProfileRideMemoryGridview extends StatefulWidget {
  const ProfileRideMemoryGridview({super.key});

  @override
  State<ProfileRideMemoryGridview> createState() => _ProfileRideMemoryGridviewState();
}

class _ProfileRideMemoryGridviewState extends State<ProfileRideMemoryGridview> {
  @override
  void initState() {
    super.initState();
    _loadAllRides();
  }

  void _loadAllRides() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<RideBloc>().add(
        GetAllRidesByUserIdEvent(
          userId: currentUser.uid,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        if (state is RideLoading) {
          return _buildLoadingGrid();
        } else if (state is AllRidesLoaded) {
          return _buildRidesGrid(state.rides);
        } else if (state is RideFailure) {
          return _buildErrorWidget(state.message);
        } else {
          // Initial state or other states - show loading
          return _buildLoadingGrid();
        }
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildRidesGrid(List<RideEntity> rides) {
    if (rides.isEmpty) {
      return SizedBox.shrink();
    }

    // Filter rides that have memories
    final ridesWithMemories = rides.where((ride) => 
      ride.rideMemories != null && ride.rideMemories!.isNotEmpty
    ).toList();
    
    if (ridesWithMemories.isEmpty) {
      return SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 0.75,
      ),
      itemCount: ridesWithMemories.length,
      itemBuilder: (context, index) {
        final ride = ridesWithMemories[index];
        
        // Check if ride has memories and if the list is not empty
        if (ride.rideMemories == null || ride.rideMemories!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final firstMemory = ride.rideMemories!.first;
        final memoryCount = ride.rideMemories!.length;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileRideMemoryDetailsScreen(ride: ride),
              ),
            );
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: firstMemory.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),

              // 🔹 Multiple images indicator
              if (memoryCount > 1)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "+${memoryCount - 1}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load rides',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllRides,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

}