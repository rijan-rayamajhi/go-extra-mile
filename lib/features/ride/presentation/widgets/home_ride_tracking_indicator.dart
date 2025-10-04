import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:go_extra_mile_new/features/ride/presentation/bloc/ride_state.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/active_ride_screen.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';

class RideTrackingIndicator extends StatelessWidget {
  const RideTrackingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RideBloc, RideState>(
      builder: (context, state) {
        // Only show if tracking is active
        if (!state.isTracking) return const SizedBox.shrink();

        // Fetch elapsed duration from RideEntity, fallback to zero
        final Duration elapsed = state.currentRide?.totalTime != null
            ? Duration(seconds: state.currentRide!.totalTime!.toInt())
            : const Duration(seconds: 0);

        final String formattedTime =
            "${elapsed.inHours.toString().padLeft(2, '0')}:${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}";

        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            baseScreenPadding,
            baseScreenPadding,
            baseScreenPadding,
            0,
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActiveRideScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(baseCardRadius),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Live indicator with animation
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: baseSpacing),
                  // Status text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride in Progress',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time display
                  Text(
                    formattedTime,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
