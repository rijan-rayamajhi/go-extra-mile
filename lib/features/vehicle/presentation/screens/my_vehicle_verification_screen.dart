import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/app_bar_widget.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';

class MyVehicleVerificationScreen extends StatefulWidget {
  final VehicleEntity vehicle;
  const MyVehicleVerificationScreen({super.key, required this.vehicle});

  @override
  State<MyVehicleVerificationScreen> createState() => _MyVehicleVerificationScreenState();
}

class _MyVehicleVerificationScreenState extends State<MyVehicleVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'My Vehicle Verification',
        centerTitle: false,
      ),
      body: Column(
        children: [
          Text('My Vehicle Verification'),
        ],
      ),
    );
  }
}