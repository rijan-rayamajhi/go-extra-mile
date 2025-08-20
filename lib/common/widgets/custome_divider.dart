import 'package:flutter/material.dart';

class CustomeDivider extends StatelessWidget {
  final String text;
   
  const CustomeDivider({super.key , required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _FadingLine(),
        ),
        const SizedBox(width: 10),
        Text(
            text.toUpperCase(), // Replace or parameterize as needed
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.5,
              color: Colors.black,
              
            ),
            
          ),
        const SizedBox(width: 10),
        const Expanded(
          child: _FadingLine(),
        ),
      ],
    );
  }
}

// Fading line widget for the divider
class _FadingLine extends StatelessWidget {
  const _FadingLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey,
            Colors.transparent,
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}