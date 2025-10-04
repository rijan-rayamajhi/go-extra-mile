import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/features/ads/presentation/widgets/carousel_ads_widget.dart';
import 'package:go_extra_mile_new/features/leaderboard/home_leaderboard_widget.dart';
import 'package:go_extra_mile_new/features/main/home_grid_view.dart';
import 'package:go_extra_mile_new/features/others/home_app_stats_widget.dart';
import 'package:go_extra_mile_new/features/profile/home_profile_image.dart';
import 'package:go_extra_mile_new/features/notification/presentation/widgets/notification_icon_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/referral/presentation/home_referral_footer_widget.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/home_recent_ride_widget.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/home_ride_stats_widget.dart';
// import 'package:go_extra_mile_new/features/ride/presentation/widgets/home_recent_ride.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/home_ride_tracking_indicator.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load user vehicles when screen initializes
    context.read<VehicleBloc>().add(
      LoadUserVehicles(FirebaseAuth.instance.currentUser?.uid ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          //profile , notification , carosel ads
          _buildHeader(),
          const SizedBox(height: 16),
          RideTrackingIndicator(),
          const SizedBox(height: 16),
          HomeGridView(),
          const SizedBox(height: 16),
          HomeRideStatsWidget(),
          const SizedBox(height: 32),
          const HomeLeaderboardWidget(),
          const SizedBox(height: 32),
          const HomeRecentRideWidget(),
          const SizedBox(height: 32),
          const HomeAppStatsWidget(),
          const SizedBox(height: 16),
          HomeReferrallFooterWidget(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Carousel ads widget
        const CarouselAdsWidget(),

        // Profile avatar widget
        const Positioned(left: 16, child: HomeProfileImage()),

        // Notification icon widget
        const Positioned(right: 16, child: NotificationIconWidget()),

        //
      ],
    );
  }
}
