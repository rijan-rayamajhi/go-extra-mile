// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// // import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
// // import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
// import 'package:share_plus/share_plus.dart';

// class ProfileRideMemoryDetailsScreen extends StatefulWidget {
//   final RideEntity ride;

//   const ProfileRideMemoryDetailsScreen({super.key, required this.ride});

//   @override
//   State<ProfileRideMemoryDetailsScreen> createState() =>
//       _ProfileRideMemoryDetailsScreenState();
// }

// class _ProfileRideMemoryDetailsScreenState
//     extends State<ProfileRideMemoryDetailsScreen> {
//   late PageController _pageController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _shareRideMemory(RideMemoryEntity rideMemory) {
//     final shareText =
//         '''
// 🚗 Ride Memory: ${rideMemory.title}

// 📝 ${rideMemory.description}

// 📅 Captured on: ${rideMemory.capturedAt.toString()}

// 📍 Location: ${rideMemory.capturedCoordinates.latitude.toStringAsFixed(5)}, ${rideMemory.capturedCoordinates.longitude.toStringAsFixed(5)}

// #GoExtraMile #RideMemory
// ''';

//     SharePlus.instance.share(
//       ShareParams(
//         text: shareText,
//         subject: 'My Ride Memory: ${rideMemory.title}',
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final images = widget.ride.rideMemories ?? [];
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             itemCount: images.length,
//             onPageChanged: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//             itemBuilder: (context, index) {
//               return CachedNetworkImage(
//                 imageUrl: images[index].imageUrl,
//                 fit: BoxFit.cover,
//                 width: double.infinity,
//                 height: double.infinity,
//               );
//             },
//           ),
//           // Indicator at bottom
//           if (images.length > 1)
//             Positioned(
//               bottom: 30,
//               left: 0,
//               right: 0,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(
//                   images.length,
//                   (index) => AnimatedContainer(
//                     duration: const Duration(milliseconds: 300),
//                     margin: const EdgeInsets.symmetric(horizontal: 4),
//                     width: _currentIndex == index ? 24 : 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: _currentIndex == index
//                           ? Colors.black
//                           : Colors.grey,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           //back button
//           Positioned(
//             top: 0,
//             left: 16,
//             child: SafeArea(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withValues(alpha: 0.6),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.white.withValues(alpha: 0.3),
//                     width: 1,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           Positioned(
//             top: 0,
//             right: 16,
//             child: SafeArea(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withValues(alpha: 0.6),
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.white.withValues(alpha: 0.3),
//                     width: 1,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: IconButton(
//                   onPressed: () => _shareRideMemory(images[_currentIndex]),
//                   icon: const Icon(Icons.share, color: Colors.white, size: 24),
//                 ),
//               ),
//             ),
//           ),

//           //position Ride Information
//           // for blur
//           Positioned(
//             bottom: 24,
//             left: 16,
//             right: 16,
//             child: SafeArea(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(
//                     sigmaX: 15,
//                     sigmaY: 15,
//                   ), // stronger blur
//                   child: Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       // Darker, more opaque background for better contrast
//                       gradient: LinearGradient(
//                         begin: Alignment.topCenter,
//                         end: Alignment.bottomCenter,
//                         colors: [
//                           Colors.black.withValues(alpha: 0.7),
//                           Colors.black.withValues(alpha: 0.8),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(
//                         color: Colors.white.withValues(alpha: 0.2),
//                         width: 1,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withValues(alpha: 0.3),
//                           blurRadius: 20,
//                           offset: const Offset(0, 8),
//                         ),
//                         BoxShadow(
//                           color: Colors.black.withValues(alpha: 0.1),
//                           blurRadius: 40,
//                           offset: const Offset(0, 16),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Title
//                         Text(
//                           images[_currentIndex].title,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.white,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black,
//                                 offset: Offset(0, 2),
//                                 blurRadius: 4,
//                               ),
//                               Shadow(
//                                 color: Colors.black54,
//                                 offset: Offset(0, 1),
//                                 blurRadius: 2,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 8),

//                         // Description
//                         Text(
//                           images[_currentIndex].description,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w400,
//                             color: Colors.white,
//                             height: 1.4,
//                             shadows: [
//                               Shadow(
//                                 color: Colors.black,
//                                 offset: Offset(0, 1),
//                                 blurRadius: 3,
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 16),

//                         // Date
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.15),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.white.withValues(alpha: 0.3),
//                               width: 0.5,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(
//                                 Icons.calendar_today,
//                                 size: 14,
//                                 color: Colors.white,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 images[_currentIndex].capturedAt.toString(),
//                                 style: const TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500,
//                                   shadows: [
//                                     Shadow(
//                                       color: Colors.black54,
//                                       offset: Offset(0, 1),
//                                       blurRadius: 2,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 8),

//                         // Coordinates
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.15),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.white.withValues(alpha: 0.3),
//                               width: 0.5,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(
//                                 Icons.location_on,
//                                 size: 14,
//                                 color: Colors.white,
//                               ),
//                               const SizedBox(width: 8),
//                               Flexible(
//                                 child: Text(
//                                   '${images[_currentIndex].capturedCoordinates.latitude.toStringAsFixed(5)}, '
//                                   '${images[_currentIndex].capturedCoordinates.longitude.toStringAsFixed(5)}',
//                                   style: const TextStyle(
//                                     fontSize: 13,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                     shadows: [
//                                       Shadow(
//                                         color: Colors.black54,
//                                         offset: Offset(0, 1),
//                                         blurRadius: 2,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
