import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/select_vehicle_type_screen.dart';

class MyVehicleNoVehicleScreen extends StatelessWidget {
  const MyVehicleNoVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Image.asset(
                'assets/images/undraw_bike-ride_ba0o.png',
                height: 200,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Vehicle',
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Register your vehicle to complete your ride, earn reward, and join exciting events.',
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SelectVehicleTypeScreen(),
                  ),
                );
              },
              text: 'Register Vehicle',
            ),
          ],
        ),
      ),
    );
  }
}
