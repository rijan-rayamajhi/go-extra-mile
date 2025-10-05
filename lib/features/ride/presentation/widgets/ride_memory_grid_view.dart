import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ride_entity.dart';
import '../bloc/ride_data_bloc.dart';
import '../bloc/ride_data_state.dart';
import '../screens/ride_memory_list_view.dart';

class RideMemoryGridView extends StatelessWidget {
  final Function(RideEntity ride)? onRideTap;

  const RideMemoryGridView({super.key, this.onRideTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideDataBloc, RideDataState>(
      builder: (context, state) {
        if (state is RideDataLoading) {
          return _buildLoadingGrid();
        }

        if (state is RideDataError) {
          return _buildErrorState(context, state.message);
        }

        if (state is RideDataLoaded) {
          // Combine remote and local rides, prioritize remote
          final allRides = [
            ...(state.remoteRides ?? []),
            ...(state.localRides ?? []),
          ];

          // Create a flat list of individual memories with their ride context
          final allMemories = <Map<String, dynamic>>[];
          for (final ride in allRides) {
            if (ride.rideMemories != null && ride.rideMemories!.isNotEmpty) {
              for (int i = 0; i < ride.rideMemories!.length; i++) {
                allMemories.add({
                  'ride': ride,
                  'memory': ride.rideMemories![i],
                  'memoryIndex': i,
                });
              }
            }
          }

          if (allMemories.isEmpty) {
            return _buildEmptyState(context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: allMemories.length,
            itemBuilder: (context, index) {
              final memoryData = allMemories[index];
              final ride = memoryData['ride'] as RideEntity;
              final memoryIndex = memoryData['memoryIndex'] as int;
              
              return RideMemoryGridItem(
                ride: ride,
                memoryIndex: memoryIndex,
                onTap: () => _navigateToMemoryListView(context, ride, memoryIndex),
              );
            },
          );
        }

        // Initial state
        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: 6, // Show 3 rows (6 items) for loading
      itemBuilder: (context, index) {
        return _ShimmerBox();
      },
    );
  }

  void _navigateToMemoryListView(BuildContext context, RideEntity ride, int memoryIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideMemoryListView(
          selectedRide: ride,
          initialMemoryIndex: memoryIndex,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Memories Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start capturing your ride moments',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class RideMemoryGridItem extends StatefulWidget {
  final RideEntity ride;
  final int memoryIndex;
  final VoidCallback? onTap;

  const RideMemoryGridItem({
    Key? key, 
    required this.ride, 
    this.memoryIndex = 0,
    this.onTap,
  }) : super(key: key);

  @override
  State<RideMemoryGridItem> createState() => _RideMemoryGridItemState();
}

class _RideMemoryGridItemState extends State<RideMemoryGridItem> {
  @override
  Widget build(BuildContext context) {
    final memories = widget.ride.rideMemories ?? [];
    final memoryCount = memories.length;
    final currentMemory = widget.memoryIndex < memories.length 
        ? memories[widget.memoryIndex] 
        : (memories.isNotEmpty ? memories.first : null);
    final additionalCount = memoryCount > 1 ? memoryCount - 1 : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (currentMemory?.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  currentMemory!.imageUrl!,
                  fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark ? Colors.grey[850] : Colors.grey[200],
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: isDark ? Colors.grey[700] : Colors.grey[400],
                      size: 32,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _ShimmerBox();
                },
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_outlined,
                  color: isDark ? Colors.grey[700] : Colors.grey[400],
                  size: 32,
                ),
              ),

            // Multiple images indicator (top-right)
            if (additionalCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.layers, color: Colors.white, size: 12),
                      const SizedBox(width: 3),
                      Text(
                        '$memoryCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Shimmer loading effect
class _ShimmerBox extends StatefulWidget {
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[850]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}
