import 'package:flutter/material.dart';

class InsureAndEarnScreen extends StatefulWidget {
  const InsureAndEarnScreen({super.key});

  @override
  State<InsureAndEarnScreen> createState() => _InsureAndEarnScreenState();
}

class _InsureAndEarnScreenState extends State<InsureAndEarnScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
        child: Text('Insure and Earn Screen'),
      ),
    );
  }
}