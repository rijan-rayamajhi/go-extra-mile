import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import 'package:share_plus/share_plus.dart';



class ProfileRideMemoryDetailsScreen extends StatefulWidget {
  final RideEntity ride;

  const ProfileRideMemoryDetailsScreen({super.key, required this.ride});

  @override
  State<ProfileRideMemoryDetailsScreen> createState() =>
      _ProfileRideMemoryDetailsScreenState();
}

class _ProfileRideMemoryDetailsScreenState
    extends State<ProfileRideMemoryDetailsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _shareRideMemory(RideMemoryEntity rideMemory) {
    final shareText = '''
🚗 Ride Memory: ${rideMemory.title}

📝 ${rideMemory.description}

📅 Captured on: ${rideMemory.capturedAt.toString()}

📍 Location: ${rideMemory.capturedCoordinates.latitude.toStringAsFixed(5)}, ${rideMemory.capturedCoordinates.longitude.toStringAsFixed(5)}

#GoExtraMile #RideMemory
''';

    Share.share(shareText, subject: 'My Ride Memory: ${rideMemory.title}');
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.ride.rideMemories ?? [];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index].imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          // Indicator at bottom
          if (images.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? Colors.black
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

          //back button
          Positioned(
            top: 0,
            left: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.3,
                  ), // semi-transparent
                  shape: BoxShape.circle, // circular button
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.3,
                  ), // semi-transparent
                  shape: BoxShape.circle, // circular button
                ),
                child: IconButton(
                  onPressed: () => _shareRideMemory(images[_currentIndex]),
                  icon: const Icon(Icons.share, color: Colors.black, size: 24),
                ),
              ),
            ),
          ),

          //position Ride Information
          // for blur
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: SafeArea(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12,
                    sigmaY: 12,
                  ), // blurred background
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3), // soft translucent
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          images[_currentIndex].title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white, // bright text
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Description
                        Text(
                          images[_currentIndex].description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Date
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              images[_currentIndex].capturedAt.toString(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Coordinates
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${images[_currentIndex].capturedCoordinates.latitude.toStringAsFixed(5)}, '
                              '${images[_currentIndex].capturedCoordinates.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
