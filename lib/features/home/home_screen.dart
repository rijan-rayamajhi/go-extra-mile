import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/rect_image.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_grid_view.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_profile_image.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_recent_ride.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_ride_progress.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true; // track initial loading

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Initial data fetch or setup
    await _refresh();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<ProfileBloc>().add(GetProfileEvent(user.uid));
        context.read<RideBloc>().add(GetCurrentRideEvent(userId: user.uid));
        context.read<RideBloc>().add(
          GetRecentRidesByUserIdEvent(
            userId: user.uid,
            limit: 1, // Get the 3 most recent rides
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        RectImage(
                          imageUrl:
                              'https://img.freepik.com/free-vector/fashion-template-design_23-2150745891.jpg',
                        ),

                        //profile icon on top left
                        Positioned(left: 16, child: HomeProfileImage()),

                        //notification on top right
                        // Positioned(
                        //   right: 16,
                        //   child: SafeArea(
                        //     child: Container(
                        //       height: 50,
                        //       width: 50,
                        //       decoration: BoxDecoration(
                        //         color: Colors.white.withValues(alpha: 0.3),
                        //         shape: BoxShape.circle,
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: Colors.black.withValues(alpha: 0.04),
                        //             blurRadius: 8,
                        //             offset: const Offset(0, 2),
                        //           ),
                        //         ],
                        //         border: Border.all(
                        //           color: Colors.grey.withValues(alpha: 0.2),
                        //         ),
                        //       ),
                        //       child: IconButton(
                        //         padding: EdgeInsets.zero,
                        //         onPressed: () {},
                        //         icon: const Icon(
                        //           Icons.notifications_outlined,
                        //           color: Colors.black,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    //active ride card
                    HomeRideProgress(),
                    const SizedBox(height: 16),

                    HomeGridView(),
                    const SizedBox(height: 24),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: HomeRecentRide(
                        
                    //   ),
                    // ),
                    // const SizedBox(height: 16),
                    Text(
                      'App Version : 0.0.3',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
    );
  }
}
