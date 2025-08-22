import 'package:flutter/material.dart';

class MyVechileScreen extends StatefulWidget {
  const MyVechileScreen({super.key});

  @override
  State<MyVechileScreen> createState() => _MyVechileScreenState();
}

class _MyVechileScreenState extends State<MyVechileScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // screen padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Vechile',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The Vechile Module be avilible in next build.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 200,),
            Center(
              child: Icon(Icons.update ,size: 40,),
            )
          ],
        ),
      ),
    );
  }
}
