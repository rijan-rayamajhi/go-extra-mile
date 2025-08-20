import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_extra_mile_new/common/widgets/app_bar_widget.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart';
import 'package:go_extra_mile_new/core/utils/text_validators.dart';
import 'package:go_extra_mile_new/core/utils/date_picker_utils.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_memory_entity.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_section.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_info_row.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';

class SaveRideScreen extends StatefulWidget {
  final RideEntity rideEntity;
  const SaveRideScreen({super.key, required this.rideEntity});

  @override
  State<SaveRideScreen> createState() => _SaveRideScreenState();
}

class _SaveRideScreenState extends State<SaveRideScreen> {

  final LocationService _locationService = LocationService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    

  String _startAddress = 'Loading...';
  String _endAddress = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadStartAddress();
    _setDefaultTitle();
  }

  void _setDefaultTitle() {
    final now = DateTime.now();
    final customLabels = {
      'morning': 'Morning Ride',
      'afternoon': 'Afternoon Adventure', 
      'evening': 'Evening Journey',
      'night': 'Night Ride',
    };
    
    final timeOfDayTitle = DatePickerUtils.getTimeOfDayLocalized(
      now, 
      customLabels: customLabels
    );
    
    _titleController.text = timeOfDayTitle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleRedeemGemCoins() {
    if (_formKey.currentState!.validate()) {
      // Dispatch UploadRideEvent
      context.read<RideBloc>().add(
        UploadRideEvent(rideEntity: widget.rideEntity),
      );

      // Note: Success message will be shown by BlocListener when RideUploaded state is emitted
    } else {
      AppSnackBar.error(context, "Please fill all the fields");
    }
  }

  void _showUnsavedRideDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unsaved Ride'),
          content: const Text(
            'Do you want to discard this ride? All ride data will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<RideBloc>().add(
                  DiscardRideEvent(userId: widget.rideEntity.userId),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Discard Ride'),
            ),
          ],
        );
      },
    );
  }


  void _loadStartAddress() async {
    final startAddress = await _locationService.getFormattedAddressFromCoordinates(
      widget.rideEntity.startCoordinates.latitude,
      widget.rideEntity.startCoordinates.longitude,
    );

    final endAddress = await _locationService.getFormattedAddressFromCoordinates(
      widget.rideEntity.endCoordinates!.latitude,
      widget.rideEntity.endCoordinates!.longitude,
    );

    if (mounted) {
      setState(() {
        _startAddress = startAddress ?? "Unknown location";
        _endAddress = endAddress ?? "Unknown location";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<RideBloc, RideState>(
      listener: (context, state) {
        if (state is RideUploaded) {
          AppSnackBar.success(context, 'Ride uploaded successfully!');
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Navigate back after successful upload
        } else if (state is RideDiscarded) {
          AppSnackBar.success(context, 'Ride discarded successfully!');
          Navigator.of(context).popUntil((route) => route.isFirst);
          // Navigate back after discarding
        } else if (state is RideFailure) {
          AppSnackBar.error(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBarWidget(
          title: 'Save Ride',
          leading: IconButton(
            onPressed: () => _showUnsavedRideDialog(),
            icon: const Icon(Icons.close),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SaveRideSection(
                  title: "Ride Info",
                  gradient: [Colors.white, Colors.grey.shade100],
                  children: [
                    SaveRideInfoRow(
                      icon: Icons.motorcycle_outlined,
                      label: "Vehicle",
                      value: widget.rideEntity.vehicleId,
                      theme: theme,
                    ),
                  ],
                ),

                // Ride Title and Description Section
                Form(
                  key: _formKey,
                  child: SaveRideSection(
                    title: "Ride Details",
                    gradient: [Colors.white, Colors.grey.shade50],
                    children: [
                      CustomTextField(
                        label: "Ride Title",
                        hintText: "Enter a title for your ride",
                        prefixIcon: Icons.title,
                        controller: _titleController,
                        textCapitalization: TextCapitalization.words,
                        validator: TextValidators.rideTitle,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: "Description",
                        hintText: "Share your ride experience...",
                        prefixIcon: Icons.description,
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.words,
                        validator: TextValidators.rideDescription,
                      ),
                    ],
                  ),
                ),
                SaveRideSection(
                  title: "Route",
                  gradient: [Colors.white, Colors.grey.shade50],
                  children: [
                    SaveRideInfoRow(
                      icon: Icons.location_on_outlined,
                      label: "Start",
                      value: _startAddress,
                      theme: theme,
                    ),
                    SaveRideInfoRow(
                      icon: Icons.flag_outlined,
                      label: "End",
                      value: _endAddress,
                      theme: theme,
                    ),
                  ],
                ),
                SaveRideSection(
                  title: "Performance",
                  gradient: [Colors.white, Colors.grey.shade100],
                  children: [
                    SaveRideInfoRow(
                      icon: Icons.route_outlined,
                      label: "Distance",
                      value: widget.rideEntity.totalDistance.toString(),
                      theme: theme,
                    ),
                    SaveRideInfoRow(
                      icon: Icons.access_time,
                      label: "Duration",
                      value: widget.rideEntity.totalTime.toString(),
                      theme: theme,
                    ),
                    SaveRideInfoRow(
                      icon: Icons.speed,
                      label: "Top Speed",
                      value: 'Comming Soon',
                      theme: theme,
                    ),
                    SaveRideInfoRow(
                      icon: Icons.directions_bike_outlined,
                      label: "Average Speed",
                      value:  'Comming Soon',
                      theme: theme,
                    ),
                  ],
                ),


               if(widget.rideEntity.rideMemories != null && widget.rideEntity.rideMemories!.isNotEmpty)...[
                
                SaveRideSection(
                  title: "Ride Memories",
                  gradient: [Colors.white, Colors.grey.shade50],
                  children: [
                    RideMemoryRoad(rideMemory: widget.rideEntity.rideMemories!, startAddress: _startAddress, endAddress: _endAddress),
                  ],
                ),
                const SizedBox(height: 16),
        
               ] else ...[
                SizedBox.shrink(),
                const SizedBox(height: 16),
               ],
                // GEM Coins Display
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade100, Colors.orange.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.amber.shade200, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/gem_coin.png',
                        width: 32,
                        height: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My GEM Coins Earning',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade800,
                            ),
                          ),
                          Text(
                            '${widget.rideEntity.totalDistance} km = ${widget.rideEntity.totalDistance} GEM coins',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                // CTA
                BlocBuilder<RideBloc, RideState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      onPressed: state is RideLoading
                          ? () {}
                          : _handleRedeemGemCoins,
                      text: state is RideLoading
                          ? 'Uploading...'
                          : 'Save & Earn',
                      // iconImage: 'assets/icons/gem_coin.png',
                    );
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RideMemoryRoad extends StatefulWidget {
  final String startAddress;
  final String endAddress;
  final List<RideMemoryEntity> rideMemory;
  const RideMemoryRoad({super.key, required this.rideMemory, required this.startAddress, required this.endAddress});

  @override
  State<RideMemoryRoad> createState() => _RideMemoryRoadState();
}

class _RideMemoryRoadState extends State<RideMemoryRoad> {
  final ScrollController _controller = ScrollController();
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!_controller.hasClients || !_controller.position.hasContentDimensions) return;

    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    setState(() {
      _progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Scrollable Road with Fade
        Stack(
          children: [
            SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                   SizedBox(width: 24,),
                  _buildMilestone(widget.startAddress),

                  for (int i = 0; i < widget.rideMemory.length; i++) ...[
                    _roadSegment(),
                    _memoryPoint(widget.rideMemory[i], i),
                  ],

                  _roadSegment(),
                  _buildMilestone(widget.endAddress),

                   SizedBox(width: 24,),
                ],
              ),
            ),

            // Fade edges
            Positioned.fill(
              child: IgnorePointer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _fadeEdge(Alignment.centerLeft),
                    _fadeEdge(Alignment.centerRight),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // 🔹 Progress Bar
        SizedBox(
          height: 4,
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _fadeEdge(Alignment alignment) {
    return Container(
      width: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: alignment,
          end: alignment == Alignment.centerLeft
              ? Alignment.centerRight
              : Alignment.centerLeft,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestone(String label) {
    return Column(
      children: [
        Image.asset(
          'assets/icons/road_milestone.png',
          width: 60,
          height: 60,
        ),
        Text(label),
      ],
    );
  }

  Widget _memoryPoint(RideMemoryEntity entity, int index) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: entity.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Text("Memory ${index + 1}"),
      ],
    );
  }

  Widget _roadSegment() {
    return SizedBox(
      width: 140,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomPaint(
          painter: DottedRoadPainter(),
        ),
      ),
    );
  }
}




class DottedRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6;
    const double dashSpace = 4;

    // Create a more curvy S-shaped road using cubic bezier curve
    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(
        size.width * 0.25, -size.height * 0.8, // exaggerated upward curve
        size.width * 0.75, size.height * 1.3, // exaggerated downward curve
        size.width, size.height * 0.5, // end point
      );

    // Draw dashed curve
    PathMetrics pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashWidth,
          startWithMoveTo: true,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }

      // 🔴 Start dot
      final startPos = metric.getTangentForOffset(0)?.position;
      if (startPos != null) {
        canvas.drawCircle(startPos, 5, Paint()..color = Colors.black);
      }

      // 🟢 End dot
      final endPos = metric.getTangentForOffset(metric.length)?.position;
      if (endPos != null) {
        canvas.drawCircle(endPos, 5, Paint()..color = Colors.black);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


