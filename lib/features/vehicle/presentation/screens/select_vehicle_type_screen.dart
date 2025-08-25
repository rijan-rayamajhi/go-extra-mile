import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/vehicle_brand_screen.dart';

class SelectVehicleTypeScreen extends StatefulWidget {
  const SelectVehicleTypeScreen({super.key});

  @override
  State<SelectVehicleTypeScreen> createState() =>
      _SelectVehicleTypeScreenState();
}

class _SelectVehicleTypeScreenState extends State<SelectVehicleTypeScreen> {
  int? selectedVehicleIndex;
  String? selectedVehicleType;

  // Static values for vehicle options
  static const List<int> _vehicleIndexes = [0, 1, 2, 3];
  static const List<String> _vehicleTitles = [
    'Two Wheeler',
    'Electric Two Wheeler',
    'Four Wheeler',
    'Electric Four Wheeler',
  ];
  static const List<String> _vehicleSubtitles = [
    'Motorcycle, Scooter',
    'E-Bike, E-Scooter',
    'Car, SUV',
    'E-Car, E-SUV',
  ];
  static const List<String> _vehicleTypes = [
    'two_wheeler',
    'two_wheeler_electric',
    'four_wheeler',
    'four_wheeler_electric',
  ];
  static const List<IconData> _vehicleIcons = [
    Icons.motorcycle,
    Icons.electric_bike,
    Icons.directions_car,
    Icons.electric_car,
  ];
  static const List<bool> _vehicleIsElectric = [false, true, false, true];

  void _handleVehicleSelection(int index) {
    setState(() {
      selectedVehicleIndex = index;
      selectedVehicleType = _vehicleTypes[index];
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleBrandScreen(selectedVehicleType: selectedVehicleType!)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your Vehicle',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Gilroy',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose your vehicle type to get started with your app journey.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildVehicleGrid(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 0.8,
      children: List.generate(
        _vehicleIndexes.length,
        (index) => _buildVehicleCard(index),
      ),
    );
  }

  Widget _buildVehicleCard(int index) {
    final isSelected = selectedVehicleIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _handleVehicleSelection(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? theme.primaryColor.withOpacity(0.1)
                        : Colors.grey[100],
                  ),
                  child: Icon(
                    _vehicleIcons[index],
                    size: 36,
                    color: isSelected ? theme.primaryColor : Colors.grey[700],
                  ),
                ),
                if (_vehicleIsElectric[index])
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Text(
                    _vehicleTitles[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? theme.primaryColor : Colors.black87,
                      fontFamily: 'Gilroy',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _vehicleSubtitles[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Gilroy',
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
