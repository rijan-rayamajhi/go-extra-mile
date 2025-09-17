import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/rect_image.dart';
import 'package:go_extra_mile_new/features/home/presentation/widgets/home_footer_widget.dart';
import 'package:go_extra_mile_new/features/home/presentation/widgets/home_grid_view.dart';
import 'package:go_extra_mile_new/features/home/presentation/widgets/home_leaderboard_widget.dart';
import 'package:go_extra_mile_new/features/home/presentation/widgets/home_profile_image.dart';
import 'package:go_extra_mile_new/features/home/presentation/widgets/home_recent_ride.dart';
import 'package:go_extra_mile_new/features/home/presentation/widgets/home_screen_shimmer.dart';
import 'package:go_extra_mile_new/features/notification/presentation/notification_screen.dart';
import 'package:go_extra_mile_new/features/home/presentation/bloc/home_bloc.dart';
import 'package:go_extra_mile_new/features/home/presentation/bloc/home_event.dart';
import 'package:go_extra_mile_new/features/home/presentation/bloc/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger loading home data when screen initializes
    context.read<HomeBloc>().add(const LoadHomeData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const HomeScreenShimmer();
        }

        if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Opps! Something went wrong',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                   TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red[300],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      context.read<HomeBloc>().add(const LoadHomeData());
                    },
                    child: const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Retry')),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is HomeLoaded) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                //play vibration
                HapticFeedback.lightImpact();
                context.read<HomeBloc>().add(const RefreshHomeData());
              },
              child: _buildBody(state),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBody(HomeLoaded state) {
    return SingleChildScrollView(
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
              Positioned(
                left: 16,
                child: HomeProfileImage(
                  profileImageUrl: state.userProfileImage,
                ),
              ),

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
                    child: Stack(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            //Navigate to notification screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.black,
                          ),
                        ),
                        // Show notification badge if there are unread notifications
                        if (state.unreadNotificationCount.isNotEmpty &&
                            int.tryParse(state.unreadNotificationCount) !=
                                null &&
                            int.parse(state.unreadNotificationCount) > 0)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Center(
                                child: Text(
                                  state.unreadNotificationCount,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // //active ride card
          // HomeRideProgress(),
          const SizedBox(height: 16),

          HomeGridView(
            unverifiedVehicleCount: state.unverifiedVehicleCount,
            unreadNotificationCount: state.unreadNotificationCount,
          ),
          const SizedBox(height: 24),
          HomeLeaderboardWidget(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: HomeRecentRide(
              remoteRides: state.remoteRides,
              localRides: state.localRides,
            ),
          ),
          const SizedBox(height: 16),

          HomeFooterWidget(
            totalGemCoins: state.totalGemCoins,
            totalDistance: state.totalDistance,
            totalRides: state.totalRides,
            referralCode: state.referralCode,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
