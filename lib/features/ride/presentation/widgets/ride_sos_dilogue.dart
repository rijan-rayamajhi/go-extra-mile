import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class RideSOSDilogue extends StatefulWidget {
  const RideSOSDilogue({super.key});

  @override
  State<RideSOSDilogue> createState() => _RideSOSDilogueState();
}

class _RideSOSDilogueState extends State<RideSOSDilogue> {
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _timer?.cancel();
            _callEmergency();
          }
        });
      }
    });
  }

  void _callEmergency() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '112');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _cancelCountdown() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.emergency, color: Colors.red, size: 28),
          SizedBox(width: 8),
          Text(
            'SOS Emergency',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Emergency call will be made in:',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: _countdown / 10.0,
                    strokeWidth: 8,
                    backgroundColor: Colors.red.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_countdown',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'seconds',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Emergency call (112) will be made automatically in loudspeaker mode',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        PrimaryButton(
          text: 'Call Now',
          onPressed: _callEmergency,
          backgroundColor: Colors.red,
        ),

        SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              _cancelCountdown();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ),
        ),
      ],
      actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
