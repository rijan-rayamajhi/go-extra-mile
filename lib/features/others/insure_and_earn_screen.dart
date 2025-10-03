import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';

class InsureAndEarnScreen extends StatefulWidget {
  const InsureAndEarnScreen({super.key});

  @override
  State<InsureAndEarnScreen> createState() => _InsureAndEarnScreenState();
}

class _InsureAndEarnScreenState extends State<InsureAndEarnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Insure and Earn'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, size: 60, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Please verify vehicle to earn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Insure and Earn',
              onPressed: () {
                AppSnackBar.info(context, 'Coming Soon');
              },
            ),
          ],
        ),
      ),
    );
  }
}
