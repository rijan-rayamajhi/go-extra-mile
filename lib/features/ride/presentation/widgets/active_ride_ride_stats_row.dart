import 'package:flutter/material.dart';

class RideStatsRow extends StatelessWidget {
  final double distanceKm;
  final double speed;
  final Duration duration;

  const RideStatsRow({
    super.key,
    required this.distanceKm,
    required this.speed,
    required this.duration,
  });

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  Widget _buildStat(String value, String label) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );

  Widget _divider() =>
      Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat("${distanceKm.toStringAsFixed(2)} km", "Distance"),
        _divider(),
        _buildStat(_formatDuration(duration), "Time"),
      ],
    );
  }
}
