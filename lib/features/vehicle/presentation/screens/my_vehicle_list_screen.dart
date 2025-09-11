import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/select_vehicle_type_screen.dart';
import '../widgets/my_vehicle_list_view_widget.dart';
import '../widgets/my_vehicle_grid_view_widget.dart';

class MyVehicleListScreen extends StatefulWidget {
  final List<VehicleEntity> vehicles;
  const MyVehicleListScreen({super.key, required this.vehicles});

  @override
  State<MyVehicleListScreen> createState() => _MyVehicleListScreenState();
}

class _MyVehicleListScreenState extends State<MyVehicleListScreen> {
  bool isListView = true;

  void _showViewToggleBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View Options',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  isListView ? Icons.grid_view : Icons.list,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(isListView ? 'Switch to Grid View' : 'Switch to List View'),
                onTap: () {
                  setState(() {
                    isListView = !isListView;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: _showViewToggleBottomSheet,
             icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SelectVehicleTypeScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Vehicle',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Content based on view type
              isListView 
                ? MyVehicleListViewWidget(vehicles: widget.vehicles)
                : MyVehicleGridViewWidget(vehicles: widget.vehicles),
            ],
          ),
        ),
      ),
    );
  }


}
