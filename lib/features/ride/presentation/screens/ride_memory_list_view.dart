import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/ride_memory_entity.dart';
import '../bloc/ride_data_bloc.dart';
import '../bloc/ride_data_state.dart';

class RideMemoryListView extends StatefulWidget {
  final RideEntity selectedRide;
  final int initialMemoryIndex;

  const RideMemoryListView({
    super.key,
    required this.selectedRide,
    this.initialMemoryIndex = 0,
  });

  @override
  State<RideMemoryListView> createState() => _RideMemoryListViewState();
}

class _RideMemoryListViewState extends State<RideMemoryListView> {
  late PageController _verticalPageController;
  PageController? _horizontalPageController;

  List<RideEntity> _allRidesWithMemories = [];
  int _currentRideIndex = 0;
  int _currentMemoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentMemoryIndex = widget.initialMemoryIndex;
    _verticalPageController = PageController();
  }

  @override
  void dispose() {
    _verticalPageController.dispose();
    _horizontalPageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Ride Memories', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: _shareMemory,
          ),
        ],
      ),
      body: BlocBuilder<RideDataBloc, RideDataState>(
        builder: (context, state) {
          if (state is RideDataLoaded) {
            _prepareRidesData(state);

            if (_allRidesWithMemories.isEmpty) {
              return _buildEmptyState();
            }

            return _buildMemoryViewer();
          }

          return _buildLoadingState();
        },
      ),
    );
  }

  void _prepareRidesData(RideDataLoaded state) {
    // Combine and filter rides with memories
    final allRides = <RideEntity>[
      ...(state.remoteRides ?? <RideEntity>[]),
      ...(state.localRides ?? <RideEntity>[]),
    ];

    _allRidesWithMemories = allRides
        .where(
          (ride) => ride.rideMemories != null && ride.rideMemories!.isNotEmpty,
        )
        .toList();

    // Find the index of the selected ride
    _currentRideIndex = _allRidesWithMemories.indexWhere(
      (ride) => ride.id == widget.selectedRide.id,
    );

    if (_currentRideIndex == -1) {
      _currentRideIndex = 0;
    }

    // Initialize horizontal controller if not already done
    if (_horizontalPageController == null && _allRidesWithMemories.isNotEmpty) {
      final selectedRide = _allRidesWithMemories[_currentRideIndex];
      final memoryCount = selectedRide.rideMemories?.length ?? 0;
      final safeInitialIndex = widget.initialMemoryIndex.clamp(
        0,
        memoryCount - 1,
      );

      _horizontalPageController = PageController(
        initialPage: memoryCount > 0 ? safeInitialIndex : 0,
      );
      _currentMemoryIndex = safeInitialIndex;
    }
  }

  Widget _buildMemoryViewer() {
    return PageView.builder(
      controller: _verticalPageController,
      scrollDirection: Axis.vertical,
      onPageChanged: (rideIndex) {
        setState(() {
          _currentRideIndex = rideIndex;
          _currentMemoryIndex = 0;
        });

        // Reset horizontal page controller to first memory of new ride
        if (_horizontalPageController?.hasClients == true) {
          _horizontalPageController?.animateToPage(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      itemCount: _allRidesWithMemories.length,
      itemBuilder: (context, rideIndex) {
        final ride = _allRidesWithMemories[rideIndex];
        final memories = ride.rideMemories ?? [];

        return _buildRideMemoryPage(ride, memories, rideIndex);
      },
    );
  }

  Widget _buildRideMemoryPage(
    RideEntity ride,
    List<RideMemoryEntity> memories,
    int rideIndex,
  ) {
    return Column(
      children: [
        // Ride info header
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                ride.rideTitle ?? 'Untitled Ride',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '${memories.length} ${memories.length == 1 ? 'Memory' : 'Memories'}',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),

        // Horizontal memory viewer
        Expanded(
          child: PageView.builder(
            controller: rideIndex == _currentRideIndex
                ? _horizontalPageController
                : null,
            onPageChanged: rideIndex == _currentRideIndex
                ? (memoryIndex) {
                    setState(() {
                      _currentMemoryIndex = memoryIndex;
                    });
                  }
                : null,
            itemCount: memories.length,
            itemBuilder: (context, memoryIndex) {
              final memory = memories[memoryIndex];
              return _buildMemoryItem(memory, memoryIndex, memories.length);
            },
          ),
        ),

        // Memory indicators
        if (memories.length > 1)
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                memories.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        rideIndex == _currentRideIndex &&
                            index == _currentMemoryIndex
                        ? Colors.white
                        : Colors.white30,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMemoryItem(
    RideMemoryEntity memory,
    int memoryIndex,
    int totalMemories,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[900],
              ),
              clipBehavior: Clip.antiAlias,
              child: memory.imageUrl != null
                  ? Image.network(
                      memory.imageUrl!,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_outlined,
                            color: Colors.white54,
                            size: 48,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No image available',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          // Memory details
          if (memory.title != null || memory.description != null)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (memory.title != null)
                    Text(
                      memory.title!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (memory.title != null && memory.description != null)
                    SizedBox(height: 8),
                  if (memory.description != null)
                    Text(
                      memory.description!,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  if (memory.capturedAt != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        _formatDateTime(memory.capturedAt!),
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_outlined, color: Colors.white54, size: 64),
          SizedBox(height: 16),
          Text(
            'No memories found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start capturing your ride moments',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _shareMemory() async {
    try {
      if (_allRidesWithMemories.isEmpty) return;
      
      final currentRide = _allRidesWithMemories[_currentRideIndex];
      final memories = currentRide.rideMemories ?? [];
      
      if (memories.isEmpty || _currentMemoryIndex >= memories.length) return;
      
      final currentMemory = memories[_currentMemoryIndex];
      
      // Build share text
      String shareText = '🏍️ Check out this ride memory!\n\n';
      
      if (currentMemory.title != null) {
        shareText += '📸 ${currentMemory.title}\n';
      }
      
      if (currentMemory.description != null) {
        shareText += '📝 ${currentMemory.description}\n';
      }
      
      shareText += '🚗 Ride: ${currentRide.rideTitle ?? 'My Ride'}\n';
      
      if (currentMemory.capturedAt != null) {
        shareText += '📅 ${_formatDateTime(currentMemory.capturedAt!)}\n';
      }
      
      shareText += '\n🌟 Shared from Go Extra Mile App';
      
      // Share with image URL if available
      if (currentMemory.imageUrl != null && currentMemory.imageUrl!.isNotEmpty) {
        await Share.share(
          shareText,
          subject: 'Ride Memory - ${currentMemory.title ?? 'My Memory'}',
        );
      } else {
        // Share text only if no image
        await Share.share(
          shareText,
          subject: 'Ride Memory - ${currentMemory.title ?? 'My Memory'}',
        );
      }
    } catch (e) {
      // Show error message if sharing fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share memory: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
