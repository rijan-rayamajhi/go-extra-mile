import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:shimmer/shimmer.dart';

class AnimatedEllipsis extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const AnimatedEllipsis({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<AnimatedEllipsis> createState() => _AnimatedEllipsisState();
}

class _AnimatedEllipsisState extends State<AnimatedEllipsis>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addListener(() {
      setState(() {
        _dotCount = (_controller.value * 4).floor() % 4;
      });
    });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _dotCount;
    return Text(
      '${widget.text}$dots',
      style: widget.style,
    );
  }
}

class HomeRideProgress extends StatefulWidget {
  final String time;
  final String distance;

  const HomeRideProgress({
    super.key,
    this.time = '00:00',
    this.distance = '0.0 km',
  });

  @override
  State<HomeRideProgress> createState() => _HomeRideProgressState();
}

class _HomeRideProgressState extends State<HomeRideProgress> {
  @override
  void initState() {
    super.initState();
    // Dispatch the event to get current ride when widget initializes
    context.read<RideBloc>().add(GetCurrentRideEvent(userId: FirebaseAuth.instance.currentUser!.uid));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        if (state is RideLoading) {
          return Container(
            width: double.infinity,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withValues(alpha: 0.3),
              highlightColor: Colors.white.withValues(alpha: 0.7),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CurrentRideLoaded) {
          if (state.ride != null) {   
          return GestureDetector(
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => RideScreen(
              //   rideEntity: state.ride!,
              //   selectedVechile: vehicles.firstWhere((v) => v['id'] == state.ride!.vehicleId, orElse: () => vehicles[0]),
              // )));
            },
            child: Container(
              width: double.infinity,
              color: Colors.red,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.motorcycle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  AnimatedEllipsis(
                    text: 'Ride in progress',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const Spacer(),
                  // // time icon
                  // const Icon(
                  //   Icons.access_time,
                  //   color: Colors.white,
                  // ),
                  // const SizedBox(width: 2),
                  // Text(
                  //   '00:00',
                  //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white,
                  //       ),
                  // ),
                  // const SizedBox(width: 10),
                  // // distance icon
                  // const Icon(
                  //   Icons.location_on,
                  //   color: Colors.white,
                  // ),
                  // const SizedBox(width: 2),
                  // Text(
                  //   '0.0 km',
                  //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.white,
                  //       ),
                  // ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
        } 
        // If no active ride or error, show nothing
        return  SizedBox.shrink();
      },
    );
  }
} 