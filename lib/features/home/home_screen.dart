import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/rect_image.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/screens/gem_coins_history_screen.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_footer_widget.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_grid_view.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_profile_image.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_recent_ride.dart';
import 'package:go_extra_mile_new/features/home/widgets/home_ride_progress.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_event.dart';
import 'package:go_extra_mile_new/features/notification/presentation/notification_screen.dart';

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

                        // notification on top right
                        Positioned(
                          right: 16,
                          child: SafeArea(
                            child: Container(
                              height: 45,
                              width: 45,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  //Navigate to notification screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                         NotificationScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    //active ride card
                    HomeRideProgress(),
                    const SizedBox(height: 16),

                    HomeGridView(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: HomeRecentRide(),
                    ),
                    const SizedBox(height: 16),

                    HomeFooterWidget(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
    );
  }
}
