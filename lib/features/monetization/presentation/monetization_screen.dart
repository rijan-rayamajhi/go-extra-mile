import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:go_extra_mile_new/common/widgets/customer_care_bottom_sheet.dart';
import 'dart:math';

import 'widgets/before_monetization_body_widget.dart';
import 'widgets/after_monetization_body_widget.dart';
import 'bloc/monetization_data_bloc.dart';
import 'bloc/monetization_data_event.dart';
import 'bloc/monetization_data_state.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_bloc.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_state.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_event.dart';

class MonetizationScreen extends StatefulWidget {
  const MonetizationScreen({super.key});

  @override
  State<MonetizationScreen> createState() => _MonetizationScreenState();
}

class _MonetizationScreenState extends State<MonetizationScreen> 
    with WidgetsBindingObserver {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Load both admin data and monetization data when screen initializes
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Reload data when app comes back to foreground
      _loadData();
    }
  }

  void _loadData() {
    context.read<AdminDataBloc>().add(FetchAdminDataEvent());
    context.read<MonetizationDataBloc>().add(const LoadMonetizationData());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDataBloc, AdminDataState>(
      builder: (context, adminState) {
        return BlocBuilder<MonetizationDataBloc, MonetizationDataState>(
          builder: (context, monetizationState) {
            // Check if user is monetized
            bool isMonetized = false;
            if (adminState is AdminDataLoaded &&
                monetizationState is MonetizationDataLoaded &&
                monetizationState.monetizationData != null) {
              final cashoutParams =
                  adminState.monetizationSettings.cashoutParams;
              isMonetized = monetizationState.monetizationData!.isMonetized(
                targetDistance: cashoutParams.minimumDistance,
                targetReferrals: cashoutParams.minimumReferrals,
                targetRides: cashoutParams.minimumRides,
              );

              // Start confetti if newly monetized
              if (isMonetized) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _confettiController.play();
                });
              }
            }

            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          CustomerCareBottomSheet.show(context);
                          // Help button action
                        },
                        icon: const Icon(Icons.contact_support_sharp),
                      ),
                    ],
                  ),
                  body: _buildBody(isMonetized, monetizationState, adminState),
                ),
                // 🎉 Confetti animation overlay
                if (isMonetized)
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirection: pi / 2, // Downward
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      numberOfParticles: 50,
                      gravity: 0.3,
                      emissionFrequency: 0.05,
                      colors: const [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.pink,
                        Colors.orange,
                        Colors.purple,
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
    bool isMonetized,
    MonetizationDataState monetizationState,
    AdminDataState adminState,
  ) {
    
    // Show error states first
    if (monetizationState is MonetizationDataError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Monetization Error: ${monetizationState.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<MonetizationDataBloc>().add(const LoadMonetizationData());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (adminState is AdminDataError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Admin Data Error: ${adminState.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AdminDataBloc>().add(FetchAdminDataEvent());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show loading states only if data is actually loading
    if (monetizationState is MonetizationDataLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading monetization data...'),
          ],
        ),
      );
    }

    if (adminState is AdminDataLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading admin settings...'),
          ],
        ),
      );
    }

    // Show content when both states are loaded and data is available
    if (monetizationState is MonetizationDataLoaded &&
        adminState is AdminDataLoaded &&
        monetizationState.monetizationData != null) {
      return isMonetized
          ? const AfterMonetizationBodyWidget()
          : BeforeMonetizationBodyWidget(
              monetizationData: monetizationState.monetizationData!,
              monetizationSettings: adminState.monetizationSettings,
            );
    }

    // If we reach here, something is wrong with the state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Admin State: ${adminState.runtimeType}'),
          Text('Monetization State: ${monetizationState.runtimeType}'),
          if (monetizationState is MonetizationDataLoaded)
            Text('Monetization Data: ${monetizationState.monetizationData != null ? 'Available' : 'Null'}'),
          const SizedBox(height: 16),
          const Text('Waiting for data to load...'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Force reload both data sources
              context.read<AdminDataBloc>().add(FetchAdminDataEvent());
              context.read<MonetizationDataBloc>().add(const LoadMonetizationData());
            },
            child: const Text('Reload Data'),
          ),
        ],
      ),
    );
  }
}
