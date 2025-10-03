import 'dart:ui';

import 'package:flutter/material.dart';

class RideTopControls extends StatelessWidget {
  final double gemCoins;
  final VoidCallback onClose;
  final VoidCallback onCurrentLocation;

  const RideTopControls({
    super.key,
    required this.gemCoins,
    required this.onClose,
    required this.onCurrentLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Close button (left)
        Positioned(
          left: 16,
          child: SafeArea(
            child: _circleButton(icon: Icons.close, onPressed: onClose),
          ),
        ),

        // Gem coin display (center)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/gem_coin.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      gemCoins.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Current location button (right)
        Positioned(
          right: 16,
          child: SafeArea(
            child: _circleButton(
              icon: Icons.my_location,
              onPressed: onCurrentLocation,
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: 24,
      ),
    );
  }
}
