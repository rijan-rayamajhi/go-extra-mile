import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/ride/domain/entities/ride_entity.dart';

class RideCardWidget extends StatefulWidget {
  final RideEntity ride;
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  const RideCardWidget({
    super.key,
    required this.ride,
    this.title,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
  });

  @override
  State<RideCardWidget> createState() => _RideCardWidgetState();
}

class _RideCardWidgetState extends State<RideCardWidget> {

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300, width: 1.2),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: widget.iconBackgroundColor ?? Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      widget.icon ?? Icons.directions_bike,
                      color: widget.iconColor ?? Colors.blue.shade700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ride.rideTitle ?? 'Untitled Ride',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Text(
                         widget.ride.rideDescription ?? 'Click to see ride details', 
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Ride date
              if (widget.ride.startedAt != null)
                Text(
                  "Started • ${DateFormat('dd MMM, hh:mm a').format(widget.ride.startedAt!)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

              if (widget.ride.endedAt != null)
                Text(
                  "Ended • ${DateFormat('dd MMM, hh:mm a').format(widget.ride.endedAt!)}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//   // Widget _rideStat(String label, String value) {
//   //   return Column(
//   //     children: [
//   //       Text(
//   //         value,
//   //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//   //       ),
//   //       const SizedBox(height: 4),
//   //       Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//   //     ],
//   //   );
//   // }

//   // Widget _divider() {
//   //   return Container(height: 28, width: 1, color: Colors.grey.shade300);
//   // }

//   // Widget _buildAddresses() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       // Start Point
//   //       Row(
//   //         children: [
//   //           Container(
//   //             width: 8,
//   //             height: 8,
//   //             decoration: BoxDecoration(
//   //               color: Colors.green,
//   //               shape: BoxShape.circle,
//   //             ),
//   //           ),
//   //           const SizedBox(width: 8),
//   //           Expanded(
//   //             child: Text(
//   //               _startAddress ?? 'Start location',
//   //               style: const TextStyle(
//   //                 fontSize: 12,
//   //                 fontWeight: FontWeight.w500,
//   //               ),
//   //               maxLines: 2,
//   //               overflow: TextOverflow.ellipsis,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //       const SizedBox(height: 8),

//   //       // End Point (if available)
//   //       if (widget.ride.endCoordinates != null) ...[
//   //         Row(
//   //           children: [
//   //             Container(
//   //               width: 8,
//   //               height: 8,
//   //               decoration: BoxDecoration(
//   //                 color: Colors.red,
//   //                 shape: BoxShape.circle,
//   //               ),
//   //             ),
//   //             const SizedBox(width: 8),
//   //             Expanded(
//   //               child: Text(
//   //                 _endAddress ?? 'End location',
//   //                 style: const TextStyle(
//   //                   fontSize: 12,
//   //                   fontWeight: FontWeight.w500,
//   //                 ),
//   //                 maxLines: 2,
//   //                 overflow: TextOverflow.ellipsis,
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ],
//   //   );
//   // }

//   // Widget _buildAddressLoading() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       Row(
//   //         children: [
//   //           Container(
//   //             width: 8,
//   //             height: 8,
//   //             decoration: BoxDecoration(
//   //               color: Colors.grey.shade400,
//   //               shape: BoxShape.circle,
//   //             ),
//   //           ),
//   //           const SizedBox(width: 8),
//   //           Expanded(
//   //             child: Container(
//   //               height: 12,
//   //               decoration: BoxDecoration(
//   //                 color: Colors.grey.shade300,
//   //                 borderRadius: BorderRadius.circular(4),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //       const SizedBox(height: 8),
//   //       Row(
//   //         children: [
//   //           Container(
//   //             width: 8,
//   //             height: 8,
//   //             decoration: BoxDecoration(
//   //               color: Colors.grey.shade400,
//   //               shape: BoxShape.circle,
//   //             ),
//   //           ),
//   //           const SizedBox(width: 8),
//   //           Expanded(
//   //             child: Container(
//   //               height: 12,
//   //               decoration: BoxDecoration(
//   //                 color: Colors.grey.shade300,
//   //                 borderRadius: BorderRadius.circular(4),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ],
//   //   );
//   // }

// }
