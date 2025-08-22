import 'package:flutter/material.dart';

class SelectVehicleTypeScreen extends StatefulWidget {

  const SelectVehicleTypeScreen({
    super.key,
  });

  @override
  State<SelectVehicleTypeScreen> createState() => _SelectVehicleTypeScreenState();
}

class _SelectVehicleTypeScreenState extends State<SelectVehicleTypeScreen> {
  int? selectedVehicleIndex;
  String? selectedVehicleType;

  final List<VehicleOption> _vehicleOptions = [
    VehicleOption(
      index: 0,
      title: 'Two Wheeler',
      subtitle: 'Motorcycle, Scooter',
      type: 'two_wheeler',
      icon: Icons.motorcycle,
    ),
    VehicleOption(
      index: 1,
      title: 'Electric Two Wheeler',
      subtitle: 'E-Bike, E-Scooter',
      type: 'two_wheeler_electric',
      icon: Icons.electric_bike,
      isElectric: true,
    ),
    VehicleOption(
      index: 2,
      title: 'Four Wheeler',
      subtitle: 'Car, SUV',
      type: 'four_wheeler',
      icon: Icons.directions_car,
    ),
    VehicleOption(
      index: 3,
      title: 'Electric Four Wheeler',
      subtitle: 'E-Car, E-SUV',
      type: 'four_wheeler_electric',
      icon: Icons.electric_car,
      isElectric: true,
    ),
  ];

  void _handleVehicleSelection(VehicleOption option) {
    setState(() {
      selectedVehicleIndex = option.index;
      selectedVehicleType = option.type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
      children: _vehicleOptions.map((option) => _buildVehicleCard(option)).toList(),
    );
  }

  Widget _buildVehicleCard(VehicleOption option) {
    final isSelected = selectedVehicleIndex == option.index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _handleVehicleSelection(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.grey[50],
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
                    color: isSelected ? theme.primaryColor.withOpacity(0.1) : Colors.grey[100],
                  ),
                  child: Icon(
                    option.icon,
                    size: 36,
                    color: isSelected ? theme.primaryColor : Colors.grey[700],
                  ),
                ),
                if (option.isElectric)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green[500],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
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
                    option.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? theme.primaryColor : Colors.black87,
                      fontFamily: 'Gilroy',
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    option.subtitle,
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

class VehicleOption {
  final int index;
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final bool isElectric;

  const VehicleOption({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.icon,
    this.isElectric = false,
  });
}