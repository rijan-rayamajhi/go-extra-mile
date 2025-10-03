import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';

class VehicleCircularImageWidget extends StatelessWidget {
  final String vehicleId;
  const VehicleCircularImageWidget({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is VehicleLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VehicleError) {
          return Center(child: Text(state.message));
        } else if (state is VehicleLoaded) {
          // Find the vehicle with matching id
          final vehicle = state.vehicles.firstWhere((v) => v.id == vehicleId);

          return CircularImage(imageUrl: vehicle.vehicleBrandImage);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
