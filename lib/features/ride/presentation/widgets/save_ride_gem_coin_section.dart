import 'package:flutter/material.dart';

class GemCoinsSection extends StatelessWidget {
  final double totalGemCoins;
  final double totalDistance;

  const GemCoinsSection({
    super.key,
    required this.totalGemCoins,
    required this.totalDistance,
  });

  @override
  Widget build(BuildContext context) {
    final gemCoinsFormatted = totalGemCoins.toStringAsFixed(2);
    // Convert distance from meters to kilometers
    final distanceInKm = (totalDistance / 1000).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/gem_coin.png', width: 32, height: 32),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My GEM Coins Earning',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade800,
                  ),
                ),
                Text(
                  '$distanceInKm km = $gemCoinsFormatted GEM coins',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.amber.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
