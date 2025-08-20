import 'package:flutter/material.dart';

class MapCircularButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;
  static const Color _defaultBackgroundColor = Colors.white;

  const MapCircularButton({
    super.key,
    required this.icon,
    this.backgroundColor = _defaultBackgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 2,
        child: IconButton(
          icon: Icon(icon, color: Colors.black),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
