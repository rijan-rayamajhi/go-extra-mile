import 'package:flutter/material.dart';

class FindAndEarnScreen extends StatefulWidget {
  const FindAndEarnScreen({super.key});

  @override
  State<FindAndEarnScreen> createState() => _FindAndEarnScreenState();
}

class _FindAndEarnScreenState extends State<FindAndEarnScreen> {
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
        title: const Text('Find and Earn'),
      ),
      body: Center(child: Text('Find and Earn Screen')),
    );
  }
}
