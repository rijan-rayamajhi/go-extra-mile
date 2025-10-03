import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/custome_divider.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_event.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_data_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/ride_details.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_card.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/recent_ride_card_shimmer.dart';

class HomeRecentRideWidget extends StatelessWidget {
  const HomeRecentRideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<RideDataBloc, RideDataState>(
          builder: (context, state) {
            if (state is RideDataInitial) {
              context.read<RideDataBloc>().add(const LoadAllRides());
            }

            if (state is RideDataLoading) {
              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CustomeDivider(text: 'Recent Ride'),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: RecentRideCardShimmer(),
                  ),
                ],
              );
            } else if (state is RideDataError) {
              return const SizedBox.shrink();
            } else if (state is RideDataLoaded) {
              final ride = state.recentRide;

              if (ride == null) return const SizedBox.shrink();

              return Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CustomeDivider(text: 'Recent Ride'),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RideCard(
                      ride: ride,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RideDetailsScreen(ride: ride),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
