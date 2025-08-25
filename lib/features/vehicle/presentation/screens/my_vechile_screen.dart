import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vehicle_no_vehicle_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vehicle_details_screen.dart';

class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  State<MyVehicleScreen> createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<VehicleBloc>(),
      child: const MyVehicleScreenContent(),
    );
  }
}

class MyVehicleScreenContent extends StatefulWidget {
  const MyVehicleScreenContent({super.key});

  @override
  State<MyVehicleScreenContent> createState() => _MyVehicleScreenContentState();
}

class _MyVehicleScreenContentState extends State<MyVehicleScreenContent> {
  
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<VehicleBloc>().add(LoadUserVehicles(currentUser.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is VehicleLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is VehicleLoaded) {
          if (state.vehicles.isNotEmpty) {
            return MyVehicleDetailsScreen(vehicles: state.vehicles);
          } else {
            return const MyVehicleNoVehicleScreen();
          }
        } else if (state is VehicleError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVehicles,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else {
          // VehicleInitial state - show loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
