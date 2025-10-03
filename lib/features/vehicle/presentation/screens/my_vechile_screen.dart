import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vehicle_no_vehicle_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vehicle_list_screen.dart';

class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  State<MyVehicleScreen> createState() => _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
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
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is VehicleLoaded) {
          if (state.vehicles.isNotEmpty) {
            return MyVehicleListScreen(vehicles: state.vehicles);
          } else {
            return const MyVehicleNoVehicleScreen();
          }
        } else if (state is VehicleError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
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
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
