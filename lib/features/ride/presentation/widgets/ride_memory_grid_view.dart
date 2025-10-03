import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ride_entity.dart';
import '../bloc/ride_data_bloc.dart';
import '../bloc/ride_data_state.dart';

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

          // Filter rides that have at least one memory
          final ridesWithMemories = allRides
              .where(
                (ride) =>
                    ride.rideMemories != null && ride.rideMemories!.isNotEmpty,
              )
              .toList();

          if (ridesWithMemories.isEmpty) {
            return _buildEmptyState(context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              childAspectRatio: 0.75,
            ),
            itemCount: ridesWithMemories.length,
            itemBuilder: (context, index) {
              final ride = ridesWithMemories[index];
              return RideMemoryGridItem(
                ride: ride,
                onTap: () => onRideTap?.call(ride),
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
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.75,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return _ShimmerBox();
      },
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
  final VoidCallback? onTap;

  const RideMemoryGridItem({Key? key, required this.ride, this.onTap})
    : super(key: key);

  @override
  State<RideMemoryGridItem> createState() => _RideMemoryGridItemState();
}

class _RideMemoryGridItemState extends State<RideMemoryGridItem> {
  @override
  Widget build(BuildContext context) {
    final memories = widget.ride.rideMemories ?? [];
    final memoryCount = memories.length;
    final firstMemory = memories.isNotEmpty ? memories.first : null;
    final additionalCount = memoryCount > 1 ? memoryCount - 1 : 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (firstMemory?.imageUrl != null)
              Image.network(
                firstMemory!.imageUrl!,
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
              )
            else
              Container(
                color: isDark ? Colors.grey[850] : Colors.grey[200],
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
