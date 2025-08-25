import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_bar_widget.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';

class MyVehicleVerificationScreen extends StatefulWidget {
  final VehicleEntity vehicle;
  const MyVehicleVerificationScreen({super.key, required this.vehicle});

  @override
  State<MyVehicleVerificationScreen> createState() =>
      _MyVehicleVerificationScreenState();
}

class _MyVehicleVerificationScreenState
    extends State<MyVehicleVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state is VehicleLoading) {
          // Show loading indicator if needed
        } else if (state is VehicleDeleted) {
          // Show success message and navigate back
          AppSnackBar.success(
            context,
            'Vehicle deleted successfully',
          );
          Navigator.pop(context);
        } else if (state is VehicleError) {
          // Show error message
          AppSnackBar.error(
            context,
            state.message,
          );
        }
      },
      child: Scaffold(
        appBar: AppBarWidget(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title:
              "${widget.vehicle.vehicleBrandName} ${widget.vehicle.vehicleModelName}",
          centerTitle: false,

          actions: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Container(
                    height: 200,
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: const Text(
                            'Delete Vehicle',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            final userId = FirebaseAuth.instance.currentUser?.uid;
                            if (userId != null) {
                              context.read<VehicleBloc>().add(
                                DeleteVehicle(widget.vehicle.id, userId),
                              );
                              Navigator.pop(context); // Close bottom sheet
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  isScrollControlled: true,
                );
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(children: [Text('My Vehicle Verification')]),
      ),
    );
  }
}
